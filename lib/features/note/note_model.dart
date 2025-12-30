// lib/features/note/note_model.dart
class NoteModel {
  final String id;
  final String status;
  final String aiTitle;
  final String aiSummary;
  final List<String> actionItems;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.status,
    required this.aiTitle,
    required this.aiSummary,
    required this.actionItems,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'ready',
      aiTitle: json['aiTitle'] ?? json['title'] ?? 'Untitled',
      aiSummary: json['aiSummary'] ?? json['summary'] ?? '',
      actionItems: (json['actionItems'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  bool get isReady => status.toLowerCase() == 'ready';
}