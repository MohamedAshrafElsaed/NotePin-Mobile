// lib/features/record/record_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'record_state.dart';
import '../../services/audio_service.dart';
import '../../core/utils/permissions.dart';

class RecordController extends ChangeNotifier {
  RecordState _state = RecordState.initial();
  Timer? _timer;
  final AudioService _audioService = AudioService();

  RecordState get state => _state;

  Future<void> startRecording() async {
    if (_state.status != RecordStatus.idle) return;

    final hasPermission = await PermissionsUtil.requestMicrophonePermission();
    if (!hasPermission) {
      _state = _state.copyWith(error: 'Microphone permission denied');
      notifyListeners();
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioService.startRecording(filePath);

      _state = _state.copyWith(
        status: RecordStatus.recording,
        remainingTime: const Duration(minutes: 30),
        audioPath: filePath,
        error: null,
      );
      notifyListeners();

      _startTimer();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to start recording: $e');
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.status != RecordStatus.recording) return;

      final newRemaining = _state.remainingTime - const Duration(seconds: 1);

      if (newRemaining.inSeconds <= 0) {
        stopRecording();
      } else {
        _state = _state.copyWith(remainingTime: newRemaining);
        notifyListeners();
      }
    });
  }

  Future<void> pauseRecording() async {
    if (_state.status != RecordStatus.recording) return;

    try {
      await _audioService.pauseRecording();
      _state = _state.copyWith(status: RecordStatus.paused);
      _timer?.cancel();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to pause: $e');
      notifyListeners();
    }
  }

  Future<void> resumeRecording() async {
    if (_state.status != RecordStatus.paused) return;

    try {
      await _audioService.resumeRecording();
      _state = _state.copyWith(status: RecordStatus.recording);
      _startTimer();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to resume: $e');
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (_state.status != RecordStatus.recording && _state.status != RecordStatus.paused) {
      return;
    }

    try {
      await _audioService.stopRecording();
      _timer?.cancel();
      _state = _state.copyWith(status: RecordStatus.stopped);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(error: 'Failed to stop: $e');
      notifyListeners();
    }
  }

  void discardRecording() {
    _timer?.cancel();
    _state = RecordState.initial();
    notifyListeners();
  }

  void setUploading() {
    _state = _state.copyWith(status: RecordStatus.uploading);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}