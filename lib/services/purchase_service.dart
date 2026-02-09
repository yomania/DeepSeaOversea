import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class PurchaseService with ChangeNotifier {
  InAppPurchase? _iap;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs
  static const String productRemoveAds = 'remove_ads';
  static const String productStarterPack = 'starter_pack';
  static const String productGemPack1 = 'gem_pack_1';

  final Set<String> _kIds = <String>{
    productRemoveAds,
    productStarterPack,
    productGemPack1,
  };

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  // Callback to notify economy provider
  Function(String productId)? onPurchaseSuccess;

  void init() {
    if (Platform.isAndroid || Platform.isIOS) {
      _iap = InAppPurchase.instance;
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _iap!.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          // proper error handling
          debugPrint('IAP Error: $error');
        },
      );

      _initialize();
    } else {
      debugPrint("IAP not supported on this platform.");
      _isAvailable = false;
      notifyListeners();
    }
  }

  Future<void> _initialize() async {
    if (_iap == null) return;
    _isAvailable = await _iap!.isAvailable();
    if (_isAvailable) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // final InAppPurchaseAndroidPlatformAddition androidAddition =
        //    _iap!.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        // await androidAddition.setBillingConfig(...); // If needed
      }

      await _loadProducts();
    }
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    if (_iap == null) return;
    ProductDetailsResponse response = await _iap!.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }
    _products = response.productDetails;
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (_iap == null) return;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if (product.id == productRemoveAds) {
      // Non-consumable
      await _iap!.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Consumable
      await _iap!.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            // Invalid purchase
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap?.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Ideally verify with backend server.
    // For now, return true for local validation.
    return true;
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    // Notify EconomyProvider
    if (onPurchaseSuccess != null) {
      onPurchaseSuccess!(purchaseDetails.productID);
    }

    _purchases.add(purchaseDetails);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
