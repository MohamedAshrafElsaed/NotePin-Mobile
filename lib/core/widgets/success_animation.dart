// lib/core/widgets/success_animation.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SuccessAnimation extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onComplete;
  final Duration duration;

  const SuccessAnimation({
    super.key,
    required this.title,
    this.subtitle,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with checkmark animation
              _AnimatedCheckmark(controller: _controller),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.title,
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.subtitle!,
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckmark extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedCheckmark({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Checkmark icon
              Icon(
                Icons.check_rounded,
                size: 48,
                color: AppColors.success.withOpacity(controller.value),
              ),
              // Ripple effect
              if (controller.value > 0.5)
                Container(
                  width: 80 * (1 + (controller.value - 0.5)),
                  height: 80 * (1 + (controller.value - 0.5)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success.withOpacity(
                        1 - ((controller.value - 0.5) * 2),
                      ),
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class SuccessOverlay extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onComplete;

  const SuccessOverlay({
    super.key,
    required this.title,
    this.subtitle,
    this.onComplete,
  });

  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlay,
      builder: (context) => SuccessOverlay(
        title: title,
        subtitle: subtitle,
        onComplete: () {
          Navigator.of(context).pop();
          onComplete?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SuccessAnimation(
          title: title,
          subtitle: subtitle,
          onComplete: onComplete,
        ),
      ),
    );
  }
}

class InlineSuccessBanner extends StatefulWidget {
  final String message;
  final Duration duration;

  const InlineSuccessBanner({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<InlineSuccessBanner> createState() => _InlineSuccessBannerState();
}

class _InlineSuccessBannerState extends State<InlineSuccessBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      )),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                widget.message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
