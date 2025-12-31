// lib/features/notes_list/data/notes_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../services/api_service.dart';
import '../../note/note_model.dart';

class NotesRepository {
  Future<List<NoteModel>> fetchNotes({int page = 1, int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/notes?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add auth token when available
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List notesJson = data['notes'] ?? [];
        return notesJson.map((json) => NoteModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw NotesRepositoryException('Authentication required');
      } else {
        throw NotesRepositoryException(
          'Failed to load notes: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NotesRepositoryException) {
        rethrow;
      }
      throw NotesRepositoryException('Network error: $e');
    }
  }

  Future<NoteModel> fetchNote(String noteId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/notes/$noteId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NoteModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw NotesRepositoryException('Note not found');
      } else {
        throw NotesRepositoryException(
          'Failed to load note: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NotesRepositoryException) {
        rethrow;
      }
      throw NotesRepositoryException('Network error: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/notes/$noteId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NotesRepositoryException(
          'Failed to delete note: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NotesRepositoryException) {
        rethrow;
      }
      throw NotesRepositoryException('Network error: $e');
    }
  }

  Future<NoteModel> updateNote(
      String noteId, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/notes/$noteId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NoteModel.fromJson(data);
      } else {
        throw NotesRepositoryException(
          'Failed to update note: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is NotesRepositoryException) {
        rethrow;
      }
      throw NotesRepositoryException('Network error: $e');
    }
  }
}

class NotesRepositoryException implements Exception {
  final String message;

  NotesRepositoryException(this.message);

  @override
  String toString() => message;
}
