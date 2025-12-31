// lib/features/notes_list/presentation/notes_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../note/note_model.dart';
import '../../note/note_screen.dart';
import '../providers/notes_provider.dart';
import 'widgets/note_card.dart';
import 'widgets/notes_search_bar.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load notes on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotesProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchBar(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingView(message: 'Loading your notes...');
          }

          if (provider.state == NotesLoadingState.error) {
            return ErrorView(
              title: 'Failed to load notes',
              message: provider.error ?? 'Unknown error',
              onRetry: provider.loadNotes,
            );
          }

          if (provider.isEmpty) {
            return _EmptyNotesView(
              onCreateNote: () => Navigator.of(context).pop(),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshNotes,
            color: AppColors.primary,
            child: Column(
              children: [
                if (provider.searchQuery.isNotEmpty)
                  NotesSearchBar(
                    query: provider.searchQuery,
                    onChanged: provider.setSearchQuery,
                    onClear: provider.clearSearch,
                  ),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: provider.notes.length +
                        (provider.state == NotesLoadingState.loadingMore
                            ? 1
                            : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == provider.notes.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final note = provider.notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => _navigateToNote(note),
                        onDelete: () => _confirmDelete(note.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.borderRadiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) {
                  context.read<NotesProvider>().setSearchQuery(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNote(NoteModel note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteScreen(note: note),
      ),
    );
  }

  void _confirmDelete(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesProvider>().deleteNote(noteId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotesView extends StatelessWidget {
  final VoidCallback onCreateNote;

  const _EmptyNotesView({required this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.note_add_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No notes yet',
              style: AppTypography.displayMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start recording or paste text to create your first note',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onCreateNote,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Note'),
            ),
          ],
        ),
      ),
    );
  }
}
