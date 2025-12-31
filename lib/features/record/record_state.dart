// lib/features/record/record_state.dart
enum RecordStatus {
  idle,
  recording,
  paused,
  stopped,
  uploading,
}

class RecordState {
  final RecordStatus status;
  final Duration remainingTime;
  final String? audioPath;
  final String? error;

  const RecordState({
    required this.status,
    required this.remainingTime,
    this.audioPath,
    this.error,
  });

  factory RecordState.initial() {
    return const RecordState(
      status: RecordStatus.idle,
      remainingTime: Duration(minutes: 30),
    );
  }

  RecordState copyWith({
    RecordStatus? status,
    Duration? remainingTime,
    String? audioPath,
    String? error,
  }) {
    return RecordState(
      status: status ?? this.status,
      remainingTime: remainingTime ?? this.remainingTime,
      audioPath: audioPath ?? this.audioPath,
      error: error ?? this.error,
    );
  }

  String get formattedTime {
    final minutes =
        remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
