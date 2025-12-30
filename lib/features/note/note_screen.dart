// lib/features/note/note_screen.dart
import 'package:flutter/material.dart';
import 'note_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class NoteScreen extends StatefulWidget {
  final NoteModel note;

  const NoteScreen({
    super.key,
    required this.note,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late List<bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = List.filled(widget.note.actionItems.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.note.isReady)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.note.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            if (!widget.note.isReady) const SizedBox(height: 16),
            Text(
              widget.note.aiTitle,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.note.createdAt.toString().split('.')[0],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Summary',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.note.aiSummary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            if (widget.note.actionItems.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Action Items',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                widget.note.actionItems.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _checkedItems[index],
                        onChanged: (value) {
                          setState(() {
                            _checkedItems[index] = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryOrange,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            widget.note.actionItems[index],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              decoration: _checkedItems[index]
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Record Another',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}