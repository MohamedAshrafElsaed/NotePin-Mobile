// lib/features/recording/providers/recording_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/permissions.dart';
import '../../../services/audio_service.dart';

enum RecordingStatus {
  idle,
  initializing,
  recording,
  paused,
  stopped,
  uploading,
}

class RecordingProvider extends ChangeNotifier {
  RecordingStatus _status = RecordingStatus.idle;
  Duration _elapsedTime = Duration.zero;
  Duration _remainingTime = const Duration(minutes: 30);
  String? _audioPath;
  String? _error;
  Timer? _timer;
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  RecordingStatus get status => _status;

  Duration get elapsedTime => _elapsedTime;

  Duration get remainingTime => _remainingTime;

  String? get audioPath => _audioPath;

  String? get error => _error;

  bool get isPlaying => _isPlaying;

  bool get canRecord => _status == RecordingStatus.idle;

  bool get isRecording => _status == RecordingStatus.recording;

  bool get isPaused => _status == RecordingStatus.paused;

  bool get isStopped => _status == RecordingStatus.stopped;

  bool get isUploading => _status == RecordingStatus.uploading;

  String get formattedElapsedTime {
    final minutes =
        _elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedRemainingTime {
    final minutes =
        _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    const maxDuration = Duration(minutes: 30);
    return _elapsedTime.inSeconds / maxDuration.inSeconds;
  }

  Future<void> startRecording() async {
    if (!canRecord) return;

    _status = RecordingStatus.initializing;
    _error = null;
    notifyListeners();

    final hasPermission = await PermissionsUtil.requestMicrophonePermission();
    if (!hasPermission) {
      _error = 'Microphone permission denied';
      _status = RecordingStatus.idle;
      notifyListeners();
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioService.startRecording(filePath);

      _audioPath = filePath;
      _status = RecordingStatus.recording;
      _elapsedTime = Duration.zero;
      _remainingTime = const Duration(minutes: 30);
      _error = null;

      _startTimer();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start recording: $e';
      _status = RecordingStatus.idle;
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status != RecordingStatus.recording) return;

      _elapsedTime += const Duration(seconds: 1);
      _remainingTime -= const Duration(seconds: 1);

      if (_remainingTime.inSeconds <= 0) {
        stopRecording();
      }

      notifyListeners();
    });
  }

  Future<void> pauseRecording() async {
    if (_status != RecordingStatus.recording) return;

    try {
      await _audioService.pauseRecording();
      _timer?.cancel();
      _status = RecordingStatus.paused;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to pause: $e';
      notifyListeners();
    }
  }

  Future<void> resumeRecording() async {
    if (_status != RecordingStatus.paused) return;

    try {
      await _audioService.resumeRecording();
      _status = RecordingStatus.recording;
      _startTimer();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to resume: $e';
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (_status != RecordingStatus.recording &&
        _status != RecordingStatus.paused) {
      return;
    }

    try {
      await _audioService.stopRecording();
      _timer?.cancel();
      _status = RecordingStatus.stopped;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop: $e';
      notifyListeners();
    }
  }

  Future<void> togglePlayback() async {
    if (_audioPath == null) return;

    if (_isPlaying) {
      await _audioService.stopPlayback();
      _isPlaying = false;
    } else {
      await _audioService.playRecording(_audioPath!);
      _isPlaying = true;

      // Auto-stop after estimated duration
      Future.delayed(_elapsedTime, () {
        if (_isPlaying) {
          _isPlaying = false;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void setUploading() {
    _status = RecordingStatus.uploading;
    notifyListeners();
  }

  void discardRecording() {
    _timer?.cancel();
    _status = RecordingStatus.idle;
    _elapsedTime = Duration.zero;
    _remainingTime = const Duration(minutes: 30);
    _audioPath = null;
    _error = null;
    _isPlaying = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
