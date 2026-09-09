import 'package:flutter/material.dart';

/// Глобальные темы приложения
class AppTheme {
  /// Фирменный яркий цвет приложения (малиновый)
  static const Color brandColor = Color(0xFFE91E63);

  /// Светлая тема
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Тёмная тема
  static ThemeData get darkTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
