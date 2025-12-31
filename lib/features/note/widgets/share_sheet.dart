// lib/features/note/widgets/share_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../note_model.dart';

class ShareSheet extends StatelessWidget {
  final NoteModel note;

  const ShareSheet({
    super.key,
    required this.note,
  });

  String _formatNoteText() {
    final buffer = StringBuffer();
    buffer.writeln(note.aiTitle);
    buffer.writeln();
    buffer.writeln('Summary:');
    buffer.writeln(note.aiSummary);

    if (note.actionItems.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Action Items:');
      for (var item in note.actionItems) {
        buffer.writeln('• $item');
      }
    }

    buffer.writeln();
    buffer.writeln('Created with NotePin');

    return buffer.toString();
  }

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
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Share Note',
            style: AppTypography.displayMedium.copyWith(fontSize: 20),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Share options
          _ShareOption(
            icon: Icons.content_copy_rounded,
            title: 'Copy to Clipboard',
            subtitle: 'Copy note text',
            onTap: () {
              Clipboard.setData(ClipboardData(text: _formatNoteText()));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Copied to clipboard'),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const Divider(height: 1),

          _ShareOption(
            icon: Icons.ios_share_rounded,
            title: 'Share via...',
            subtitle: 'Share using other apps',
            onTap: () {
              // TODO: Implement native share when plugin is available
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Native sharing coming soon!'),
                ),
              );
            },
          ),

          const Divider(height: 1),

          _ShareOption(
            icon: Icons.email_rounded,
            title: 'Send via Email',
            subtitle: 'Open in email app',
            onTap: () {
              // TODO: Implement email sharing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email sharing coming soon!'),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusSmall,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headingSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
