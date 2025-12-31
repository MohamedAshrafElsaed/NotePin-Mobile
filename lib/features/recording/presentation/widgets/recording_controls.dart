// lib/features/recording/presentation/widgets/recording_controls.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RecordingControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isPrimary;

  const RecordingControlButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 64,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isPrimary ? AppColors.primary : AppColors.surface),
            shape: BoxShape.circle,
            border: !isPrimary
                ? Border.all(color: AppColors.border, width: 2)
                : null,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? AppColors.primary)
                          .withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color:
                iconColor ?? (isPrimary ? Colors.white : AppColors.textPrimary),
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}

class AnimatedRecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onPressed;

  const AnimatedRecordButton({
    super.key,
    required this.isRecording,
    this.onPressed,
  });

  @override
  State<AnimatedRecordButton> createState() => _AnimatedRecordButtonState();
}

class _AnimatedRecordButtonState extends State<AnimatedRecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isRecording ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: widget.isRecording ? AppColors.error : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppColors.error
                            : AppColors.primary)
                        .withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecordingControlsRow extends StatelessWidget {
  final bool isPaused;
  final VoidCallback? onPauseResume;
  final VoidCallback? onStop;
  final VoidCallback? onDiscard;

  const RecordingControlsRow({
    super.key,
    required this.isPaused,
    this.onPauseResume,
    this.onStop,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onDiscard != null) ...[
          RecordingControlButton(
            icon: Icons.delete_outline_rounded,
            onPressed: onDiscard,
            backgroundColor: AppColors.errorLight,
            iconColor: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
        RecordingControlButton(
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onPressed: onPauseResume,
          size: 72,
        ),
        const SizedBox(width: AppSpacing.lg),
        RecordingControlButton(
          icon: Icons.stop_rounded,
          onPressed: onStop,
          backgroundColor: AppColors.primary,
          iconColor: Colors.white,
          size: 72,
          isPrimary: true,
        ),
      ],
    );
  }
}
