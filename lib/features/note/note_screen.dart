// lib/features/note/note_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import 'note_model.dart';
import 'widgets/share_sheet.dart';

class NoteScreen extends StatefulWidget {
  final NoteModel note;

  const NoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late List<bool> _checkedItems;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _checkedItems = List.filled(widget.note.actionItems.length, false);

    // Show success animation on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _showSuccessAnimation = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccessAnimation = false);
        }
      });
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  int get _completedCount => _checkedItems.where((checked) => checked).length;

  int get _totalCount => _checkedItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).popUntil(
            (route) => route.isFirst,
          ),
        ),
        title: const Text('Your Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareNote,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copyToClipboard();
                  break;
                case 'edit':
                  _showEditDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Copy to clipboard'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Edit note'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge (if not ready)
                if (!widget.note.isReady) ...[
                  StatusBadge(
                    text: widget.note.status.toUpperCase(),
                    type: StatusBadgeType.warning,
                    icon: Icons.schedule_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Title
                Text(
                  widget.note.aiTitle,
                  style: AppTypography.displayLarge.copyWith(fontSize: 28),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatDate(widget.note.createdAt),
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Summary Card
                _SectionCard(
                  title: 'Summary',
                  icon: Icons.description_rounded,
                  child: Text(
                    widget.note.aiSummary,
                    style: AppTypography.bodyLarge.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),

                // Action Items Card
                if (widget.note.actionItems.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    title: 'Action Items',
                    icon: Icons.checklist_rounded,
                    badge: _totalCount > 0
                        ? '$_completedCount / $_totalCount'
                        : null,
                    child: Column(
                      children: List.generate(
                        widget.note.actionItems.length,
                        (index) => _ActionItemTile(
                          text: widget.note.actionItems[index],
                          isChecked: _checkedItems[index],
                          onChanged: (value) {
                            setState(() {
                              _checkedItems[index] = value ?? false;
                            });
                            if (value == true) {
                              _showCheckAnimation(index);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Action Buttons
                PrimaryButton(
                  text: 'Record Another Note',
                  icon: Icons.mic_rounded,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                OutlinedButton.icon(
                  onPressed: _shareNote,
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Note'),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Success overlay
          if (_showSuccessAnimation) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.overlay,
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: AppSpacing.animationSlow),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadiusLarge,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          size: 48,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Note Ready!',
                        style: AppTypography.displayMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showCheckAnimation(int index) {
    HapticFeedback.mediumImpact();
  }

  void _shareNote() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareSheet(note: widget.note),
    );
  }

  void _copyToClipboard() {
    final text = '''
${widget.note.aiTitle}

Summary:
${widget.note.aiSummary}

${widget.note.actionItems.isNotEmpty ? 'Action Items:\n${widget.note.actionItems.map((item) => '• $item').join('\n')}' : ''}

Created with NotePin
    ''';

    Clipboard.setData(ClipboardData(text: text));
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
      ),
    );
  }

  void _showEditDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note editing coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ActionItemTile extends StatelessWidget {
  final String text;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const _ActionItemTile({
    required this.text,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!isChecked),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      text,
                      style: AppTypography.bodyLarge.copyWith(
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
