// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundLight = Color(0xFFFFF7ED);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primaryOrange,
        secondary: primaryOrange,
        surface: Colors.white,
        surfaceContainerLowest: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textGrey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}