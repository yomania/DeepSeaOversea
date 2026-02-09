
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/economy_provider.dart';
import '../../constants/game_constants.dart';
import '../../services/purchase_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEEP SEA MARKET'),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), height: 1),
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Consumer<EconomyProvider>(
        builder: (context, economy, child) {
          final units = economy.visibleUnits;
          final purchaseService = context.watch<PurchaseService>();
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- UPGRADES / IAP ---
              Text('SUPPLIES & UPGRADES', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.cyanAccent)),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildIapCard(context, economy, purchaseService, 'Remove Ads', PurchaseService.productRemoveAds, Icons.cancel_presentation, 'Permanent'),
                    _buildIapCard(context, economy, purchaseService, 'Starter Pack', PurchaseService.productStarterPack, Icons.backpack, '+1000 Minerals'),
                    _buildIapCard(context, economy, purchaseService, 'Gem Pack', PurchaseService.productGemPack1, Icons.diamond, '+50k Minerals'),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- UNITS ---
              Text('AUTOMATION UNITS', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.cyanAccent)),
              const SizedBox(height: 10),
              ...units.map((unit) {
                final canAfford = economy.canAffordUnit(unit.id);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: canAfford ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Unit Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.precision_manufacturing, color: Colors.cyan),
                      ),
                      const SizedBox(width: 16),
                      
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unit.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            Text(unit.description, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                            const SizedBox(height: 4),
                            Text('Owned: ${unit.count}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                          ],
                        ),
                      ),
                      
                      // Buy Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? Colors.green : Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: canAfford ? () => economy.buyUnit(unit.id) : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('BUY'),
                            Text('${unit.currentCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIapCard(BuildContext context, EconomyProvider economy, PurchaseService service, String title, String prodId, IconData icon, String subtitle) {
    // Check if already purchased (e.g. remove ads)
    bool isPurchased = (prodId == PurchaseService.productRemoveAds && economy.removeAdsPurchased);
    
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isPurchased ? Colors.grey[900] : Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isPurchased ? Colors.green : Colors.cyan.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isPurchased ? null : () {
             // Find product detail
             try {
                final product = service.products.firstWhere((p) => p.id == prodId, orElse: () => throw 'Product not found');
                service.buyProduct(product);
             } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Store not available (Mock: $prodId clicked)")));
                // For testing/mocking without real store:
                // service.onPurchaseSuccess?.call(prodId); 
             }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isPurchased ? Icons.check_circle : icon, size: 30, color: isPurchased ? Colors.green : Colors.cyanAccent),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
