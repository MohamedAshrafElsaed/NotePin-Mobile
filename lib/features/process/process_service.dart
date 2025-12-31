// lib/features/process/process_service.dart
import '../../services/ai_service.dart';
import '../note/note_model.dart';

class ProcessService {
  final AiService _aiService = AiService();

  Future<NoteModel> pollForResult(String recordingId) async {
    return await _aiService.pollForNote(recordingId);
  }
}
