// lib/features/notes_list/providers/notes_provider.dart
import 'package:flutter/foundation.dart';

import '../../note/note_model.dart';
import '../data/notes_repository.dart';

enum NotesLoadingState {
  idle,
  loading,
  refreshing,
  loadingMore,
  loaded,
  error,
}

class NotesProvider extends ChangeNotifier {
  final NotesRepository _repository = NotesRepository();

  NotesLoadingState _state = NotesLoadingState.idle;
  List<NoteModel> _notes = [];
  String? _error;
  String _searchQuery = '';
  bool _hasMore = true;
  int _currentPage = 1;

  NotesLoadingState get state => _state;

  List<NoteModel> get notes => _searchQuery.isEmpty
      ? _notes
      : _notes
          .where((note) =>
              note.aiTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.aiSummary.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  String? get error => _error;

  bool get hasMore => _hasMore;

  bool get isEmpty => _notes.isEmpty && _state == NotesLoadingState.loaded;

  bool get isLoading => _state == NotesLoadingState.loading;

  bool get isRefreshing => _state == NotesLoadingState.refreshing;

  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    if (_state == NotesLoadingState.loading) return;

    _state = NotesLoadingState.loading;
    _error = null;
    notifyListeners();

    try {
      _notes = await _repository.fetchNotes(page: 1);
      _currentPage = 1;
      _hasMore = _notes.length >= 20; // Assume 20 per page
      _state = NotesLoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = NotesLoadingState.error;
    }

    notifyListeners();
  }

  Future<void> refreshNotes() async {
    _state = NotesLoadingState.refreshing;
    notifyListeners();

    try {
      _notes = await _repository.fetchNotes(page: 1);
      _currentPage = 1;
      _hasMore = _notes.length >= 20;
      _state = NotesLoadingState.loaded;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _state = NotesLoadingState.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_hasMore || _state == NotesLoadingState.loadingMore) return;

    _state = NotesLoadingState.loadingMore;
    notifyListeners();

    try {
      final newNotes = await _repository.fetchNotes(page: _currentPage + 1);
      _notes.addAll(newNotes);
      _currentPage++;
      _hasMore = newNotes.length >= 20;
      _state = NotesLoadingState.loaded;
    } catch (e) {
      _state = NotesLoadingState.loaded;
    }

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    try {
      await _repository.deleteNote(noteId);
      _notes.removeWhere((note) => note.id == noteId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete note: $e';
      notifyListeners();
    }
  }

  void addNote(NoteModel note) {
    _notes.insert(0, note);
    notifyListeners();
  }
}
