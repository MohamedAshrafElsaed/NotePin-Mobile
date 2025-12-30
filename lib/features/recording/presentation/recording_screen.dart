// lib/features/recording/presentation/recording_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/api_service.dart';
import '../providers/recording_provider.dart';
import '../../process/process_screen.dart';
import 'widgets/waveform_visualizer.dart';
import 'widgets/recording_controls.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordingProvider(),
      child: const _RecordingScreenContent(),
    );
  }
}

class _RecordingScreenContent extends StatefulWidget {
  const _RecordingScreenContent();

  @override
  State<_RecordingScreenContent> createState() => _RecordingScreenContentState();
}

class _RecordingScreenContentState extends State<_RecordingScreenContent> {
  @override
  void initState() {
    super.initState();
    // Auto-start recording when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordingProvider>().startRecording();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _handleClose(context),
        ),
        title: Consumer<RecordingProvider>(
          builder: (context, provider, _) {
            return Text(_getStatusText(provider.status));
          },
        ),
      ),
      body: Consumer<RecordingProvider>(
        builder: (context, provider, _) {
          if (provider.status == RecordingStatus.idle ||
              provider.status == RecordingStatus.initializing) {
            return const _InitializingView();
          }

          if (provider.status == RecordingStatus.uploading) {
            return const _UploadingView();
          }

          if (provider.status == RecordingStatus.stopped) {
            return _StoppedView(
              provider: provider,
              onUpload: () => _handleUpload(context, provider),
              onDiscard: () => _handleDiscard(context, provider),
              onPlayPause: provider.togglePlayback,
            );
          }

          return _RecordingView(
            provider: provider,
            onPauseResume: () => _handlePauseResume(provider),
            onStop: provider.stopRecording,
          );
        },
      ),
    );
  }

  String _getStatusText(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.idle:
      case RecordingStatus.initializing:
        return 'Initializing...';
      case RecordingStatus.recording:
        return 'Recording';
      case RecordingStatus.paused:
        return 'Paused';
      case RecordingStatus.stopped:
        return 'Recording Complete';
      case RecordingStatus.uploading:
        return 'Uploading...';
    }
  }

  void _handlePauseResume(RecordingProvider provider) {
    if (provider.isPaused) {
      provider.resumeRecording();
    } else {
      provider.pauseRecording();
    }
  }

  void _handleClose(BuildContext context) {
    final provider = context.read<RecordingProvider>();

    if (provider.isRecording || provider.isPaused) {
      _showDiscardDialog(context, provider);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showDiscardDialog(BuildContext context, RecordingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Recording?'),
        content: const Text(
          'Are you sure you want to discard this recording? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.discardRecording();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close screen
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _handleDiscard(BuildContext context, RecordingProvider provider) {
    _showDiscardDialog(context, provider);
  }

  Future<void> _handleUpload(
      BuildContext context,
      RecordingProvider provider,
      ) async {
    if (provider.audioPath == null) return;

    provider.setUploading();

    try {
      final apiService = ApiService();
      final result = await apiService.uploadRecording(provider.audioPath!);

      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProcessScreen(recordingId: result['id']),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );

      provider.discardRecording();
    }
  }
}

class _InitializingView extends StatelessWidget {
  const _InitializingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Preparing microphone...',
            style: AppTypography.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  final RecordingProvider provider;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  const _RecordingView({
    required this.provider,
    required this.onPauseResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),

            // Timer Display
            Text(
              provider.formattedElapsedTime,
              style: AppTypography.displayLarge.copyWith(
                fontSize: 56,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Remaining time
            Text(
              '${provider.formattedRemainingTime} remaining',
              style: AppTypography.bodyMedium,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Waveform Visualizer
            WaveformVisualizer(
              isActive: provider.isRecording,
              color: AppColors.primary,
              height: 100,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Progress indicator
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),

            const Spacer(),

            // Controls
            RecordingControlsRow(
              isPaused: provider.isPaused,
              onPauseResume: onPauseResume,
              onStop: onStop,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _StoppedView extends StatelessWidget {
  final RecordingProvider provider;
  final VoidCallback onUpload;
  final VoidCallback onDiscard;
  final VoidCallback onPlayPause;

  const _StoppedView({
    required this.provider,
    required this.onUpload,
    required this.onDiscard,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),

            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 56,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Recording Complete',
              style: AppTypography.displayMedium,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Duration: ${provider.formattedElapsedTime}',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Play/Pause button
            OutlinedButton.icon(
              onPressed: onPlayPause,
              icon: Icon(
                provider.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(provider.isPlaying ? 'Stop Preview' : 'Play Preview'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            PrimaryButton(
              text: 'Upload & Process',
              icon: Icons.cloud_upload_rounded,
              onPressed: onUpload,
            ),

            const SizedBox(height: AppSpacing.sm),

            OutlinedButton(
              onPressed: onDiscard,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Discard Recording'),
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _UploadingView extends StatelessWidget {
  const _UploadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Uploading recording...',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This may take a moment',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}