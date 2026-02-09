import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/economy_provider.dart';
import '../../models/skill_model.dart';
import '../widgets/skill_tree_painter.dart';
import '../widgets/skill_node_widget.dart';
import '../../constants/game_constants.dart';

class SkillScreen extends StatefulWidget {
  const SkillScreen({super.key});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final double _gridSize = 120.0;
  final double _nodeSize = 80.0;

  bool _isCentered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final economy = Provider.of<EconomyProvider>(context);
    final skills = economy.visibleSkills; // List<SkillModel>
    final skillMap = {for (var s in skills) s.id: s};

    // Calculate canvas size based on nodes spread
    // We assume a reasonable fixed canvas size for the InteractiveViewer content
    final canvasSize = const Size(2000, 2000);
    final centerOffset = Offset(canvasSize.width / 2, canvasSize.height / 2);

    return Scaffold(
      backgroundColor: Colors.black, // Deep Sea background
      appBar: AppBar(
        title: const Text('Research Lab'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // XP / Level Indicator in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Lvl ${economy.level} (XP: ${economy.xp.toStringAsFixed(0)}/${economy.xpToNextLevel.toStringAsFixed(0)})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!_isCentered) {
            _isCentered = true;
            final canvasCenter = const Offset(1000, 1000); // Half of 2000x2000
            // Calculate center based on actual available space (excluding AppBar)
            final x = constraints.maxWidth / 2 - canvasCenter.dx;
            final y = constraints.maxHeight / 2 - canvasCenter.dy;

            _transformationController.value = Matrix4.identity()
              ..translate(x, y)
              ..scale(1.0);
          }

          return Stack(
            children: [
              // Infinite(ish) Grid/Background pattern could go here
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(
                  500.0,
                ), // Allow panning far out
                minScale: 0.1,
                maxScale: 2.5,
                constrained: false, // Infinite canvas
                child: SizedBox(
                  width: canvasSize.width,
                  height: canvasSize.height,
                  child: Stack(
                    children: [
                      // 1. Draw connections (Painter)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SkillTreePainter(
                            skills: skillMap,
                            gridSize: _gridSize,
                            centerOffset: centerOffset,
                          ),
                        ),
                      ),

                      // 2. Draw Nodes
                      ...skills.map((skill) {
                        final left =
                            centerOffset.dx +
                            skill.x * _gridSize -
                            (_nodeSize / 2);
                        final top =
                            centerOffset.dy +
                            skill.y * _gridSize -
                            (_nodeSize / 2);

                        return Positioned(
                          left: left,
                          top: top,
                          child: SkillNodeWidget(
                            skill: skill,
                            size: _nodeSize,
                            isAvailable: economy.canAffordSkill(skill.id),
                            onTap: () =>
                                _showSkillDetails(context, skill, economy),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // HUD overlay (Resources)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Minerals: ${economy.getResourceAmount(GameConstants.resourceMinerals).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.cyan, fontSize: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSkillDetails(
    BuildContext context,
    SkillModel skill,
    EconomyProvider economy,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      isScrollControlled: true,
      builder: (context) {
        final canAfford = economy.canAffordSkill(skill.id);

        return Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                skill.description,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 20),
              const Divider(color: Colors.grey),
              const SizedBox(height: 10),

              // Requirements
              if (skill.requiredLevel > 0)
                Text(
                  'Requires Level ${skill.requiredLevel}',
                  style: TextStyle(
                    color: economy.level >= skill.requiredLevel
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              if (skill.resourceCost.isNotEmpty)
                ...skill.resourceCost.entries.map((e) {
                  final current = economy.getResourceAmount(e.key);
                  final hasEnough = current >= e.value;
                  return Text(
                    'Cost: ${e.value.toStringAsFixed(0)} ${e.key}', // Using ID as name for now
                    style: TextStyle(
                      color: hasEnough ? Colors.cyan : Colors.red,
                    ),
                  );
                }),

              const SizedBox(height: 30),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (skill.isPurchased || !canAfford)
                      ? null
                      : () {
                          economy.buySkill(skill.id);
                          Navigator.pop(context); // Close modal
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFFF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    skill.isPurchased
                        ? 'PURCHASED'
                        : canAfford
                        ? 'RESEARCH'
                        : 'LOCKED / INSUFFICIENT FUNDS',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
