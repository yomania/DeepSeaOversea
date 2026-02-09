import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/economy_provider.dart';
import '../../constants/game_constants.dart';
import '../../constants/app_config.dart';
import '../widgets/particle_widget.dart';
import 'shop_screen.dart';
import 'skill_screen.dart';

import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _bobbingController;
  late Animation<double> _bobbingAnimation;

  // Ore Event
  bool _isOreVisible = false;
  double _oreTop = 0;
  double _oreLeft = 0;
  Timer? _oreTimer;

  @override
  void initState() {
    super.initState();

    // Bobbing Animation (Floating effect)
    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bobbingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _bobbingController, curve: Curves.easeInOut),
    );

    // Start Ore Event Scheduler
    _scheduleOreEvent();
  }

  void _scheduleOreEvent() {
    _oreTimer = Timer(Duration(seconds: Random().nextInt(10) + 10), () {
      if (mounted) {
        setState(() {
          _isOreVisible = true;
          // Random position within safe area (roughly)
          // Adjust based on screen size, currently hardcoded for safety
          _oreTop = Random().nextDouble() * 300 + 100; // 100 ~ 400
          _oreLeft = Random().nextDouble() * 200 + 20; // 20 ~ 220
        });

        // Disappear after 5 seconds if not clicked
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _isOreVisible) {
            setState(() {
              _isOreVisible = false;
            });
            _scheduleOreEvent();
          }
        });
      }
    });
  }

  void _onOreClicked(EconomyProvider economy) {
    economy.manualClickWithBonus(10.0); // 10x Click Bonus
    setState(() {
      _isOreVisible = false;
    });
    _scheduleOreEvent();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rare Ore Found! +10x Minerals!'),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.amber,
      ),
    );
  }

  @override
  void dispose() {
    _bobbingController.dispose();
    _oreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ParticleWidgetState> particleKey = GlobalKey();

    return Scaffold(
      backgroundColor: Colors.black, // 기본 배경색
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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
                      color: Colors.black.withOpacity(0.5), // 반투명 검정 배경
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                              triggerMode: TooltipTriggerMode
                                  .tap, // Tap to see on mobile
                              showDuration: const Duration(seconds: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+${economy.mineralsPerSecond.toStringAsFixed(1)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
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
                              // Jellyfish Decoration (Animated)
                              AnimatedBuilder(
                                animation: _bobbingAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: 100 + _bobbingAnimation.value,
                                    right: 50,
                                    child: child!,
                                  );
                                },
                                child: Opacity(
                                  opacity: 0.8,
                                  child: Image.asset(
                                    'assets/images/jellyfish.png',
                                    width: 80,
                                  ),
                                ),
                              ),

                              AnimatedBuilder(
                                animation: _bobbingAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    bottom:
                                        150 +
                                        (_bobbingAnimation.value *
                                            -1), // Reverse move
                                    left: 30,
                                    child: child!,
                                  );
                                },
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Image.asset(
                                    'assets/images/jellyfish.png',
                                    width: 60,
                                  ),
                                ),
                              ),

                              // Ore Event
                              if (_isOreVisible)
                                Positioned(
                                  top: _oreTop,
                                  left: _oreLeft,
                                  child: GestureDetector(
                                    onTap: () => _onOreClicked(economy),
                                    child: Image.asset(
                                      'assets/images/ore.png',
                                      width: 60,
                                    ),
                                  ),
                                ),

                              // Main Submarine (Animated)
                              AnimatedBuilder(
                                animation: _bobbingAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _bobbingAnimation.value),
                                    child: child,
                                  );
                                },
                                child: Image.asset(
                                  'assets/images/submarine.png',
                                  width: 250,
                                ),
                              ),

                              Positioned(
                                bottom: 100,
                                child: Text(
                                  "TAP TO EXPLORE",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
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
                          MaterialPageRoute(
                            builder: (_) => const SkillScreen(),
                          ),
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
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.black,
                      ),
                    ),
                    if (AppConfig.enableCheats)
                      IconButton(
                        onPressed: () => _showDebugMenu(context),
                        icon: const Icon(
                          Icons.bug_report,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Test Mode',
                      ), // Debug/Settings
                  ],
                ),
              ),
            ],
          ),
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
