// lib/services/ai_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/note/note_model.dart';
import 'api_service.dart';

class AiService {
  static const int maxAttempts = 60;
  static const Duration pollInterval = Duration(seconds: 2);

  Future<NoteModel> pollForNote(String recordingId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/recordings/$recordingId/json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ready') {
          return NoteModel.fromJson(data);
        } else if (data['status'] == 'processing') {
          // Still processing, return non-ready note
          return NoteModel.fromJson(data);
        } else if (data['status'] == 'error') {
          throw AiProcessingException(
            'Processing failed: ${data['error'] ?? 'Unknown error'}',
          );
        }
      } else if (response.statusCode == 404) {
        throw AiProcessingException(
          'Recording not found. Please try uploading again.',
        );
      } else if (response.statusCode >= 500) {
        throw AiProcessingException(
          'Server error. Please try again later.',
        );
      }

      // Return processing status for any other case
      return NoteModel.fromJson({
        'id': recordingId,
        'status': 'processing',
        'aiTitle': 'Processing...',
        'aiSummary': 'Your note is being processed.',
        'actionItems': [],
        'createdAt': DateTime.now().toIso8601String(),
      });
    } on AiProcessingException {
      rethrow;
    } catch (e) {
      throw AiProcessingException(
        'Failed to check processing status: ${e.toString()}',
      );
    }
  }

  Future<NoteModel> waitForCompletion(String recordingId) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final note = await pollForNote(recordingId);

        if (note.isReady) {
          return note;
        }
      } catch (e) {
        if (e is AiProcessingException) {
          rethrow;
        }
        // Continue polling on transient errors
      }

      await Future.delayed(pollInterval);
      attempts++;
    }

    throw AiProcessingException(
      'Processing timeout. The AI is taking longer than expected. Please try again.',
    );
  }
}

class AiProcessingException implements Exception {
  final String message;

  AiProcessingException(this.message);

  @override
  String toString() => message;
}
