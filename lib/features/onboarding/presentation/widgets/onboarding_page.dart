// lib/features/onboarding/presentation/widgets/onboarding_page.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFinalPage;
  final Color iconColor;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFinalPage = false,
    this.iconColor = AppColors.primary,
  });
}

class OnboardingPage extends StatefulWidget {
  final OnboardingPageData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Animated icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.data.iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.data.icon,
                  size: 64,
                  color: widget.data.iconColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.data.title,
              style: AppTypography.displayLarge.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Subtitle
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.data.subtitle,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
