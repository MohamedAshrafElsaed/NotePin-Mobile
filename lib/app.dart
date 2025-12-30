// lib/app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/record/record_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotePin',
      theme: AppTheme.theme,
      home: const RecordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}