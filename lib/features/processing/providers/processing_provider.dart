// lib/features/processing/providers/processing_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../services/ai_service.dart';
import '../../note/note_model.dart';

enum ProcessingStep {
  uploading,
  transcribing,
  analyzing,
  extracting,
  finalizing,
  complete,
  error,
}

class ProcessingProvider extends ChangeNotifier {
  ProcessingStep _currentStep = ProcessingStep.uploading;
  double _progress = 0.0;
  String? _error;
  NoteModel? _result;
  final String recordingId;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const int maxAttempts = 60;

  ProcessingProvider({required this.recordingId});

  ProcessingStep get currentStep => _currentStep;
  double get progress => _progress;
  String? get error => _error;
  NoteModel? get result => _result;
  bool get isComplete => _currentStep == ProcessingStep.complete;
  bool get hasError => _currentStep == ProcessingStep.error;

  String get stepTitle {
    switch (_currentStep) {
      case ProcessingStep.uploading:
        return 'Uploading...';
      case ProcessingStep.transcribing:
        return 'Transcribing audio...';
      case ProcessingStep.analyzing:
        return 'Analyzing content...';
      case ProcessingStep.extracting:
        return 'Extracting insights...';
      case ProcessingStep.finalizing:
        return 'Finalizing...';
      case ProcessingStep.complete:
        return 'Complete!';
      case ProcessingStep.error:
        return 'Processing failed';
    }
  }

  String get stepDescription {
    switch (_currentStep) {
      case ProcessingStep.uploading:
        return 'Preparing your recording';
      case ProcessingStep.transcribing:
        return 'Converting speech to text';
      case ProcessingStep.analyzing:
        return 'Understanding context';
      case ProcessingStep.extracting:
        return 'Finding action items and key points';
      case ProcessingStep.finalizing:
        return 'Creating your note';
      case ProcessingStep.complete:
        return 'Your note is ready!';
      case ProcessingStep.error:
        return _error ?? 'Something went wrong';
    }
  }

  Future<void> startProcessing() async {
    _simulateProgressSteps();
    await _pollForResult();
  }

  void _simulateProgressSteps() {
    // Simulate progress through steps while we poll
    Timer(const Duration(seconds: 1), () {
      if (_currentStep == ProcessingStep.uploading) {
        _updateStep(ProcessingStep.transcribing, 0.2);
      }
    });

    Timer(const Duration(seconds: 3), () {
      if (_currentStep == ProcessingStep.transcribing) {
        _updateStep(ProcessingStep.analyzing, 0.4);
      }
    });

    Timer(const Duration(seconds: 5), () {
      if (_currentStep == ProcessingStep.analyzing) {
        _updateStep(ProcessingStep.extracting, 0.6);
      }
    });

    Timer(const Duration(seconds: 7), () {
      if (_currentStep == ProcessingStep.extracting) {
        _updateStep(ProcessingStep.finalizing, 0.8);
      }
    });
  }

  void _updateStep(ProcessingStep step, double progress) {
    if (_currentStep != ProcessingStep.error &&
        _currentStep != ProcessingStep.complete) {
      _currentStep = step;
      _progress = progress;
      notifyListeners();
    }
  }

  Future<void> _pollForResult() async {
    final aiService = AiService();

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_pollAttempts >= maxAttempts) {
        timer.cancel();
        _handleError('Processing timeout. Please try again.');
        return;
      }

      _pollAttempts++;

      try {
        final note = await aiService.pollForNote(recordingId);

        if (note.isReady) {
          timer.cancel();
          _result = note;
          _updateStep(ProcessingStep.complete, 1.0);
        }
      } catch (e) {
        // Continue polling on individual errors
        debugPrint('Poll attempt $_pollAttempts failed: $e');

        if (_pollAttempts >= maxAttempts) {
          timer.cancel();
          _handleError('Processing took too long. Please try again.');
        }
      }
    });
  }

  void _handleError(String message) {
    _error = message;
    _currentStep = ProcessingStep.error;
    notifyListeners();
  }

  Future<void> retry() async {
    _currentStep = ProcessingStep.uploading;
    _progress = 0.0;
    _error = null;
    _result = null;
    _pollAttempts = 0;
    notifyListeners();

    await startProcessing();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}