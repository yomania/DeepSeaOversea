import 'package:flutter/material.dart';
import '../../models/skill_model.dart';

class SkillTreePainter extends CustomPainter {
  final Map<String, SkillModel> skills;
  final double gridSize;
  final Offset centerOffset;

  SkillTreePainter({
    required this.skills,
    required this.gridSize,
    required this.centerOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final unlockedPaint = Paint()
      ..color = const Color(0xFF00FFFF)
          .withOpacity(0.8) // Cyan for unlocked paths
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (var skill in skills.values) {
      // Calculate current node position
      final startX = centerOffset.dx + skill.x * gridSize;
      final startY = centerOffset.dy + skill.y * gridSize;
      final startPoint = Offset(startX, startY);

      // Draw lines to dependencies (parents)
      // Note: We draw logic from Child -> Parent or Parent -> Child depending on perspective.
      // Here, let's look at requirements. If this skill requires 'A', draw line from 'A' to 'this'.

      for (var parentId in skill.requiredSkillIds) {
        final parent = skills[parentId];
        if (parent != null) {
          final endX = centerOffset.dx + parent.x * gridSize;
          final endY = centerOffset.dy + parent.y * gridSize;
          final endPoint = Offset(endX, endY);

          // If both are purchased (or just checked purchased?), color the line
          // Or if parent is purchased and child is unlocked?
          // Let's say if BOTH are purchased, the connection is fully active (Cyan).
          // Otherwise grey.
          bool isActive = skill.isPurchased && parent.isPurchased;

          canvas.drawLine(
            endPoint,
            startPoint,
            isActive ? unlockedPaint : paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simple repaint for now, optimize later if needed
  }
}
