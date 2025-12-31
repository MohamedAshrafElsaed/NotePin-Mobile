// lib/core/widgets/permission_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class PermissionDialog {
  static Future<void> showMicrophonePermissionDialog(
    BuildContext context, {
    required VoidCallback onGranted,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PermissionDialog(
        title: 'Microphone Access Required',
        message:
            'NotePin needs access to your microphone to record voice notes. Your privacy is important - recordings are only processed when you choose to upload them.',
        icon: Icons.mic_rounded,
        permissionName: 'Microphone',
      ),
    );

    if (result == true) {
      onGranted();
    }
  }

  static Future<void> showPermissionDeniedDialog(
    BuildContext context, {
    required String permissionName,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$permissionName Permission Denied',
          style: AppTypography.headingLarge,
        ),
        content: Text(
          'Please enable $permissionName access in your device settings to use this feature.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _PermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String permissionName;

  const _PermissionDialog({
    required this.title,
    required this.message,
    required this.icon,
    required this.permissionName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.displayMedium.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Grant Access',
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
