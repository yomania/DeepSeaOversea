
import 'dart:math';
import 'package:flutter/material.dart';

class ParticleWidget extends StatefulWidget {
  final Widget child;
  const ParticleWidget({super.key, required this.child});

  @override
  State<ParticleWidget> createState() => ParticleWidgetState();
}

class ParticleWidgetState extends State<ParticleWidget> with TickerProviderStateMixin {
  final List<_Particle> _particles = [];
  final Random _random = Random();

  void spawnParticle(TapUpDetails details) {
    setState(() {
      _particles.add(_Particle(
        position: details.localPosition,
        controller: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        )..forward().then((_) {
            // Cleanup happens in build via loop or listener, but simple way:
            // removing closed controllers is trickier in list without setState.
            // We'll let the listing cleanup based on status.
          }),
        angle: _random.nextDouble() * 2 * pi,
        speed: _random.nextDouble() * 50 + 50,
      ));
    });
  }

  @override
  void dispose() {
    for (var p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cleanup finished particles
    _particles.removeWhere((p) {
      if (p.controller.isCompleted) {
        p.controller.dispose();
        return true;
      }
      return false;
    });

    return GestureDetector(
      onTapUp: spawnParticle,
      child: Stack(
        children: [
          widget.child,
          ..._particles.map((p) => AnimatedBuilder(
            animation: p.controller,
            builder: (context, child) {
              final progress = p.controller.value;
              final dx = cos(p.angle) * p.speed * progress;
              final dy = sin(p.angle) * p.speed * progress - (50 * progress); // Float up slightly
              
              return Positioned(
                left: p.position.dx + dx - 10, // Center
                top: p.position.dy + dy - 10,
                child: Opacity(
                  opacity: 1.0 - progress,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.cyanAccent.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.4),
                          blurRadius: 5,
                        )
                      ]
                    ),
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class _Particle {
  final Offset position;
  final AnimationController controller;
  final double angle;
  final double speed;

  _Particle({
    required this.position,
    required this.controller,
    required this.angle,
    required this.speed,
  });
}
