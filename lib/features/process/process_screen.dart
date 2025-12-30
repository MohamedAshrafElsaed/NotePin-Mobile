// lib/features/process/process_screen.dart
import 'package:flutter/material.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/primary_button.dart';
import 'process_service.dart';
import '../note/note_screen.dart';

class ProcessScreen extends StatefulWidget {
  final String recordingId;

  const ProcessScreen({
    super.key,
    required this.recordingId,
  });

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  final ProcessService _processService = ProcessService();
  bool _isProcessing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final note = await _processService.pollForResult(widget.recordingId);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NoteScreen(note: note),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isProcessing
            ? const LoadingView(
          message: 'AI is processing your note...',
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Processing failed',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Retry',
                onPressed: _startProcessing,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Back to recording'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}