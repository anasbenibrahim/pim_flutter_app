import 'package:flutter/material.dart';
import '../../features/hopi/cubit/hopi_state.dart';

/// Generates a Flutter ThemeData from Hopi's current mood.
///
/// Usage:
///   theme: HopiTheme.fromMood(hopiState.mood),
class HopiTheme {
  HopiTheme._();

  /// Generate a full ThemeData from a HopiMood.
  static ThemeData fromMood(HopiMood mood) {
    final palette = HopiPalette.forMood(mood);
    final isDark = mood == HopiMood.sad || mood == HopiMood.anxious;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: palette.primary,
              secondary: palette.secondary,
              surface: palette.surface,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: palette.textPrimary,
            )
          : ColorScheme.light(
              primary: palette.primary,
              secondary: palette.secondary,
              surface: palette.surface,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: palette.textPrimary,
            ),
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.cardColor,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: palette.textPrimary),
        bodyMedium: TextStyle(color: palette.textSecondary),
      ),
    );
  }

  /// Generate a dark theme variant from a HopiMood.
  static ThemeData darkFromMood(HopiMood mood) {
    final palette = HopiPalette.forMood(mood);
    final darkBg = HSLColor.fromColor(palette.background)
        .withLightness(0.12)
        .toColor();
    final darkCard = HSLColor.fromColor(palette.cardColor)
        .withLightness(0.22)
        .toColor();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        secondary: palette.secondary,
        surface: darkBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white70,
      ),
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: palette.primary,
        unselectedItemColor: Colors.white54,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
