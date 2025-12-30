// lib/features/text_input/presentation/text_input_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/api_service.dart';
import '../../process/process_screen.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final int _minChars = 10;
  final int _maxChars = 20000;
  bool _isProcessing = false;

  int get _currentLength => _textController.text.length;
  bool get _isValid => _currentLength >= _minChars && _currentLength <= _maxChars;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color _getCounterColor() {
    if (_currentLength < _minChars) {
      return AppColors.textTertiary;
    } else if (_currentLength > _maxChars) {
      return AppColors.error;
    }
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paste Text'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paste your meeting notes, chat transcript, or any text',
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _textController,
                      maxLines: null,
                      minLines: 12,
                      maxLength: _maxChars,
                      style: AppTypography.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Paste or type here...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        counterText: '',
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          _isValid
                              ? Icons.check_circle_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: _getCounterColor(),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$_currentLength / $_maxChars characters',
                          style: AppTypography.bodySmall.copyWith(
                            color: _getCounterColor(),
                          ),
                        ),
                        const Spacer(),
                        if (_currentLength < _minChars)
                          Text(
                            '${_minChars - _currentLength} more needed',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    if (_currentLength > _maxChars) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.borderRadiusSmall,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Text is too long. Please reduce to ${_maxChars} characters.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: PrimaryButton(
                text: 'Process Text',
                onPressed: _isValid && !_isProcessing ? _processText : null,
                isLoading: _isProcessing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processText() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final apiService = ApiService();

      // TODO: Replace with actual text processing endpoint
      // For now, we'll simulate uploading text as a recording
      final result = await apiService.uploadText(_textController.text);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProcessScreen(recordingId: result['id']),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process text: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}