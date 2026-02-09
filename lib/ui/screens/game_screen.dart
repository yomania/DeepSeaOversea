import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/economy_provider.dart';
import '../../constants/game_constants.dart';
import '../widgets/particle_widget.dart';
import 'shop_screen.dart';
import 'skill_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ParticleWidgetState> particleKey = GlobalKey();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Resources
            Consumer<EconomyProvider>(
              builder: (context, economy, child) {
                final minerals = economy.getResourceAmount(
                  GameConstants.resourceMinerals,
                );
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MINERALS',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          Text(
                            minerals.toStringAsFixed(0),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PER SEC',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          Tooltip(
                            message: economy.getProductionBreakdown(),
                            triggerMode:
                                TooltipTriggerMode.tap, // Tap to see on mobile
                            showDuration: const Duration(seconds: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+${economy.mineralsPerSecond.toStringAsFixed(1)}',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.greenAccent),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Main Click Area (Depth / Visuals)
            Expanded(
              child: ParticleWidget(
                key: particleKey,
                child: Consumer<EconomyProvider>(
                  builder: (context, economy, _) {
                    return GestureDetector(
                      onTapUp: (details) {
                        economy.manualClick();
                        particleKey.currentState?.spawnParticle(details);
                      },
                      child: Container(
                        color: Colors.transparent, // Hit test
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background Elements (Bubbles, fog - placeholders)
                            Positioned(
                              bottom: 100,
                              child: Icon(
                                Icons.water_drop,
                                size: 200,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                              ),
                            ),

                            Text(
                              "TAP TO MINE",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.2),
                                letterSpacing: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom Menu
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SkillScreen()),
                      );
                    },
                    icon: const Icon(Icons.science, color: Colors.cyanAccent),
                    tooltip: 'Research & Skills',
                  ),
                  FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ShopScreen()),
                      );
                    },
                    child: const Icon(Icons.shopping_cart, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () => _showDebugMenu(context),
                    icon: const Icon(Icons.bug_report, color: Colors.redAccent),
                    tooltip: 'Test Mode',
                  ), // Debug/Settings
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDebugMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final economy = Provider.of<EconomyProvider>(context, listen: false);
        return AlertDialog(
          title: const Text('Test / Cheat Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upgrade, color: Colors.amber),
                title: const Text('Level Up'),
                onTap: () {
                  economy.debugLevelUp();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.cyan),
                title: const Text('Add 1000 Minerals'),
                onTap: () {
                  economy.debugAddMinerals(1000);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text('Subtract 1000 Minerals'),
                onTap: () {
                  economy.debugSubMinerals(1000);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
