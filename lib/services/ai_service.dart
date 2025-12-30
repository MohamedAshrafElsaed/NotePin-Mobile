// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/note/note_model.dart';
import 'api_service.dart';

class AiService {
  static const int maxAttempts = 60;
  static const Duration pollInterval = Duration(seconds: 2);

  Future<NoteModel> pollForNote(String recordingId) async {
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/recordings/$recordingId/json'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'ready') {
            return NoteModel.fromJson(data);
          }
        }
      } catch (e) {
        // Continue polling on error
      }

      await Future.delayed(pollInterval);
      attempts++;
    }

    throw Exception('Timeout: AI processing took too long');
  }
}