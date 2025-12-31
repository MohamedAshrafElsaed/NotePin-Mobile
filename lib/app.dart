// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

class NotePinApp extends StatelessWidget {
  const NotePinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotePin',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<OnboardingProvider>(
        builder: (context, onboarding, _) {
          if (onboarding.isComplete) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
