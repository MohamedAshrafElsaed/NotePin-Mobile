// lib/features/auth/presentation/auth_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

class AuthModal extends StatelessWidget {
  const AuthModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusLarge),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'Sign in to save your notes',
            style: AppTypography.displayMedium.copyWith(fontSize: 22),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            'Access your notes from any device and keep them synced',
            style: AppTypography.bodyMedium,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Google Sign In Button
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return _GoogleSignInButton(
                onPressed: () async {
                  await auth.signIn();
                  if (context.mounted && auth.isAuthenticated) {
                    Navigator.of(context).pop();
                  }
                },
                isLoading: auth.isLoading,
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Terms
          Center(
            child: Text(
              'By signing in, you agree to our Terms of Service\nand Privacy Policy',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          side: const BorderSide(color: AppColors.border),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image not found
                      return const Icon(
                        Icons.login_rounded,
                        size: 20,
                        color: AppColors.primary,
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Continue with Google',
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
