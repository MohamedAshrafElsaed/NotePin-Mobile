// lib/features/recording/presentation/widgets/timer_display.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class TimerDisplay extends StatefulWidget {
  final Duration duration;
  final bool isActive;
  final String? label;

  const TimerDisplay({
    super.key,
    required this.duration,
    this.isActive = true,
    this.label,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    if (widget.isActive) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _blinkController.repeat(reverse: true);
      } else {
        _blinkController.stop();
        _blinkController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  String _formatDuration() {
    final minutes = widget.duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = widget.duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isActive)
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(_blinkController.value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            Text(
              _formatDuration(),
              style: AppTypography.displayLarge.copyWith(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                fontFeatures: [
                  const FontFeature.tabularFigures(), // Monospace numbers
                ],
              ),
            ),
          ],
        ),
        if (widget.label != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.label!,
            style: AppTypography.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class CircularTimerProgress extends StatelessWidget {
  final double progress;
  final Duration duration;
  final Color color;
  final double size;

  const CircularTimerProgress({
    super.key,
    required this.progress,
    required this.duration,
    this.color = AppColors.primary,
    this.size = 200,
  });

  String _formatDuration() {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.borderLight,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Time text
          Text(
            _formatDuration(),
            style: AppTypography.displayLarge.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}