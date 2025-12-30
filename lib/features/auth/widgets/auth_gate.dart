// lib/features/auth/widgets/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../presentation/auth_modal.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  final String? message;
  final String? title;

  const AuthGate({
    super.key,
    required this.child,
    this.message,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return child;
        }

        return _AuthRequiredView(
          title: title,
          message: message,
        );
      },
    );
  }
}

class _AuthRequiredView extends StatelessWidget {
  final String? title;
  final String? message;

  const _AuthRequiredView({
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title ?? 'Sign In Required',
              style: AppTypography.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ??
                  'Sign in to save and sync your notes across all your devices.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Sign In',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AuthModal(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AuthGateDialog {
  static Future<bool> show(
      BuildContext context, {
        String? title,
        String? message,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Sign In Required'),
        content: Text(
          message ?? 'You need to sign in to access this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AuthModal(),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}