// lib/core/widgets/confetti_animation.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfettiAnimation extends StatefulWidget {
  final Duration duration;

  const ConfettiAnimation({
    super.key,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _initializeParticles();
    _controller.forward();
  }

  void _initializeParticles() {
    const particleCount = 50;
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      Colors.purple,
      Colors.pink,
    ];

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1,
          vx: (_random.nextDouble() - 0.5) * 0.5,
          vy: _random.nextDouble() * 0.5 + 0.3,
          rotation: _random.nextDouble() * pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
          size: _random.nextDouble() * 10 + 5,
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      final newY = particle.y + (particle.vy * progress);
      final newX = particle.x + (particle.vx * progress);
      final newRotation = particle.rotation + (particle.rotationSpeed * progress * 10);

      // Skip if particle is off screen
      if (newY > 1.2 || newX < -0.2 || newX > 1.2) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        newX * size.width,
        newY * size.height,
      );
      canvas.rotate(newRotation);

      // Draw confetti piece (rectangle)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.5,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class ConfettiOverlay extends StatelessWidget {
  final Widget child;
  final bool showConfetti;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showConfetti)
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiAnimation(),
            ),
          ),
      ],
    );
  }
}