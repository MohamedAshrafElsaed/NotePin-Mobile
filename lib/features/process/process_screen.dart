// lib/features/process/process_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/error_view.dart';
import '../note/note_screen.dart';
import '../processing/presentation/widgets/processing_animation.dart';
import '../processing/providers/processing_provider.dart';

class ProcessScreen extends StatelessWidget {
  final String recordingId;

  const ProcessScreen({
    super.key,
    required this.recordingId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProcessingProvider(recordingId: recordingId)..startProcessing(),
      child: const _ProcessScreenContent(),
    );
  }
}

class _ProcessScreenContent extends StatelessWidget {
  const _ProcessScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProcessingProvider>(
        builder: (context, provider, _) {
          // Auto-navigate when complete
          if (provider.isComplete && provider.result != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => NoteScreen(note: provider.result!),
                  ),
                );
              }
            });
          }

          if (provider.hasError) {
            return _ErrorView(
              error: provider.error ?? 'Unknown error',
              onRetry: provider.retry,
              onCancel: () => Navigator.of(context).popUntil(
                (route) => route.isFirst,
              ),
            );
          }

          return _ProcessingView(
            step: provider.currentStep,
            progress: provider.progress,
            title: provider.stepTitle,
            description: provider.stepDescription,
          );
        },
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  final ProcessingStep step;
  final double progress;
  final String title;
  final String description;

  const _ProcessingView({
    required this.step,
    required this.progress,
    required this.title,
    required this.description,
  });

  int get _stepIndex {
    switch (step) {
      case ProcessingStep.uploading:
        return 0;
      case ProcessingStep.transcribing:
        return 1;
      case ProcessingStep.analyzing:
        return 2;
      case ProcessingStep.extracting:
        return 3;
      case ProcessingStep.finalizing:
        return 4;
      case ProcessingStep.complete:
        return 5;
      case ProcessingStep.error:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // Main animation
            const ProcessingAnimation(
              size: 120,
              color: AppColors.primary,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Step indicators
            StepIndicator(
              currentStep: _stepIndex,
              totalSteps: 5,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Title
            AnimatedSwitcher(
              duration: Duration(milliseconds: AppSpacing.animationNormal),
              child: Text(
                title,
                key: ValueKey(title),
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Description
            AnimatedSwitcher(
              duration: Duration(milliseconds: AppSpacing.animationNormal),
              child: Text(
                description,
                key: ValueKey(description),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Processing steps list
            _ProcessingStepsList(currentStep: _stepIndex),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ProcessingStepsList extends StatelessWidget {
  final int currentStep;

  const _ProcessingStepsList({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepInfo(
        icon: Icons.cloud_upload_rounded,
        title: 'Upload',
        description: 'Sending your recording',
      ),
      _StepInfo(
        icon: Icons.transcribe_rounded,
        title: 'Transcribe',
        description: 'Converting to text',
      ),
      _StepInfo(
        icon: Icons.psychology_rounded,
        title: 'Analyze',
        description: 'Understanding context',
      ),
      _StepInfo(
        icon: Icons.lightbulb_rounded,
        title: 'Extract',
        description: 'Finding key insights',
      ),
      _StepInfo(
        icon: Icons.check_circle_rounded,
        title: 'Finalize',
        description: 'Creating your note',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(
          steps.length,
          (index) => _ProcessingStepItem(
            info: steps[index],
            isActive: index == currentStep,
            isComplete: index < currentStep,
            isLast: index == steps.length - 1,
          ),
        ),
      ),
    );
  }
}

class _StepInfo {
  final IconData icon;
  final String title;
  final String description;

  _StepInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ProcessingStepItem extends StatelessWidget {
  final _StepInfo info;
  final bool isActive;
  final bool isComplete;
  final bool isLast;

  const _ProcessingStepItem({
    required this.info,
    required this.isActive,
    required this.isComplete,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : isComplete
                        ? AppColors.success
                        : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : info.icon,
                color: isActive || isComplete
                    ? Colors.white
                    : AppColors.textTertiary,
                size: 20,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: AppTypography.headingSmall.copyWith(
                      color: isActive || isComplete
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: isActive || isComplete
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator for active step
            if (isActive)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
          ],
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(
              left: 20,
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            width: 2,
            height: 20,
            color: isComplete ? AppColors.success : AppColors.borderLight,
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            ErrorView(
              title: 'Processing Failed',
              message: error,
              onRetry: onRetry,
              retryButtonText: 'Try Again',
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: onCancel,
              child: const Text('Back to Home'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
