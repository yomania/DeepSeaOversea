
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:hive/hive.dart';
import '../models/resource_model.dart';
import '../models/unit_model.dart';
import '../constants/game_constants.dart';
import '../services/purchase_service.dart';

class EconomyProvider with ChangeNotifier {
  late Box<ResourceModel> _resourceBox;
  late Box<UnitModel> _unitBox;

  Timer? _gameTimer;
  DateTime? _lastTick;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Resources map for O(1) access
  Map<String, ResourceModel> _resources = {};
  Map<String, UnitModel> _units = {};

  double _mineralsPerSecond = 0.0;
  double get mineralsPerSecond => _mineralsPerSecond;
  
  // IAP Integration
  PurchaseService? _purchaseService;
  set purchaseService(PurchaseService service) {
    _purchaseService = service;
    _purchaseService?.onPurchaseSuccess = _handlePurchaseSuccess;
    notifyListeners();
  }
  
  bool _removeAdsPurchased = false; 
  bool get removeAdsPurchased => _removeAdsPurchased;

  Future<void> init() async {
    if (_isInitialized) return;

    _resourceBox = await Hive.openBox<ResourceModel>(GameConstants.boxResources);
    _unitBox = await Hive.openBox<UnitModel>(GameConstants.boxUnits);

    _initializeResources();
    _initializeUnits();
    
    _recalculateProduction();

    _startGameLoop();
    _isInitialized = true;
    notifyListeners();
  }

  void _initializeResources() {
    if (_resourceBox.isEmpty) {
      _resources[GameConstants.resourceMinerals] = ResourceModel(
        id: GameConstants.resourceMinerals,
        name: 'Minerals',
        description: 'Basic resource found in the ocean.',
      );
      _resourceBox.add(_resources[GameConstants.resourceMinerals]!);
    } else {
      for (var res in _resourceBox.values) {
        _resources[res.id] = res;
      }
    }
  }

  void _handlePurchaseSuccess(String productId) {
    if (productId == PurchaseService.productRemoveAds) {
      _removeAdsPurchased = true;
      // Maybe give a persistent buff?
      _recalculateProduction();
    } else if (productId == PurchaseService.productStarterPack) {
      // Give resources
      _resources[GameConstants.resourceMinerals]?.add(1000.0);
      _resources[GameConstants.resourceGas]?.add(100.0);
    } else if (productId == PurchaseService.productGemPack1) {
      // Give Gems (if implemented) or massive minerals
      _resources[GameConstants.resourceMinerals]?.add(50000.0);
    }
    notifyListeners();
  }

  void _initializeUnits() {
    if (_unitBox.isEmpty) {
      // Manual Clicker (virtual unit)
      _units[GameConstants.unitClick] = UnitModel(
        id: GameConstants.unitClick,
        name: 'Manual Harvest',
        description: 'Click to harvest resources.',
        baseCost: 0, 
        baseProduction: 1.0, // Base click power
        count: 1,
        isUnlocked: true,
      );
      
      // Auto Miner
      _units[GameConstants.unitAutoMiner] = UnitModel(
        id: GameConstants.unitAutoMiner,
        name: 'Auto Miner',
        description: 'Basic automated mining machine.',
        baseCost: 15.0,
        baseProduction: 0.5,
      );

       // Save all
       _units.forEach((key, value) {
         _unitBox.add(value);
       });

    } else {
      for (var unit in _unitBox.values) {
        _units[unit.id] = unit;
      }
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _lastTick = DateTime.now();
    
    // 10 ticks per second for smooth UI, but logic can be adjusted
    _gameTimer = Timer.periodic(Duration(milliseconds: GameConstants.tickMilliseconds), (timer) {
      final now = DateTime.now();
      final delta = now.difference(_lastTick!).inMilliseconds / 1000.0;
      _lastTick = now;

      _produceResources(delta);
    });
  }

  void _produceResources(double deltaSeconds) {
    if (_mineralsPerSecond > 0) {
      final production = _mineralsPerSecond * deltaSeconds;
      _resources[GameConstants.resourceMinerals]?.add(production);
      notifyListeners(); // Notify UI to update numbers
    }
  }

  void _recalculateProduction() {
    double mps = 0.0;
    
    // Sum up all auto-production units (excluding manual click for MPS)
    for (var unit in _units.values) {
      if (unit.id != GameConstants.unitClick) {
        mps += unit.totalProduction;
      }
    }
    
    // Apply global multipliers (Upgrades, IAP)
    if (_removeAdsPurchased) {
      mps *= 1.2; // 20% bonus for Remove Ads as an example benefit
    }
    
    _mineralsPerSecond = mps;
  }

  // --- Public Actions ---

  void manualClick() {
    final clickPower = _units[GameConstants.unitClick]?.totalProduction ?? 1.0;
    _resources[GameConstants.resourceMinerals]?.add(clickPower);
    HapticFeedback.lightImpact(); // Haptic feedback
    notifyListeners();
  }

  bool canAffordUnit(String unitId) {
    final unit = _units[unitId];
    final minerals = _resources[GameConstants.resourceMinerals]?.amount ?? 0;
    if (unit == null) return false;
    return minerals >= unit.currentCost;
  }

  void buyUnit(String unitId) {
    final unit = _units[unitId];
    final mineralsRes = _resources[GameConstants.resourceMinerals];
    
    if (unit != null && mineralsRes != null) {
      final cost = unit.currentCost;
      if (mineralsRes.amount >= cost) {
        mineralsRes.subtract(cost);
        unit.purchase();
        _recalculateProduction();
        notifyListeners();
      }
    }
  }

  double getResourceAmount(String resourceId) {
    return _resources[resourceId]?.amount ?? 0.0;
  }
  
  UnitModel? getUnit(String unitId) {
    return _units[unitId];
  }

  List<UnitModel> get visibleUnits {
    // Return units that should be shown in the store
    return _units.values.where((u) => u.id != GameConstants.unitClick).toList();
  }
  
  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
