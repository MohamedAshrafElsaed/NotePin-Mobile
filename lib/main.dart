// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/notes_list/providers/notes_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider(prefs)),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const NotePinApp(),
    ),
  );
}
