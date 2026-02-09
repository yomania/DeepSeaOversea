import 'package:flutter/material.dart';
import '../../models/skill_model.dart';

class SkillNodeWidget extends StatelessWidget {
  final SkillModel skill;
  final double size;
  final bool isAvailable; // Can be purchased?
  final VoidCallback onTap;

  const SkillNodeWidget({
    super.key,
    required this.skill,
    required this.size,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on state
    Color borderColor = Colors.grey;
    Color iconColor = Colors.white54;
    Color backgroundColor = Colors.black87;

    if (skill.isPurchased) {
      borderColor = const Color(0xFF00FFFF); // Cyan
      iconColor = const Color(0xFF00FFFF);
      backgroundColor = const Color(0xFF003333);
    } else if (skill.isUnlocked) {
      if (isAvailable) {
        borderColor = Colors.amber; // Available to buy
        iconColor = Colors.amber;
      } else {
        borderColor = Colors.white; // Unlocked but maybe not enough resources
        iconColor = Colors.white;
      }
    } else {
      // Locked (dependencies not met)
      borderColor = Colors.grey.shade800;
      iconColor = Colors.grey.shade800;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 3.0),
          boxShadow: skill.isPurchased
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            _getIconForSkill(skill.id),
            color: iconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }

  IconData _getIconForSkill(String id) {
    if (id.contains('efficiency')) return Icons.bolt;
    if (id.contains('autominer')) return Icons.precision_manufacturing;
    if (id.contains('click')) return Icons.touch_app;
    return Icons.star;
  }
}
