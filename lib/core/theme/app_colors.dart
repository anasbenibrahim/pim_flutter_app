import 'package:flutter/material.dart';

class AppColors {
  // Primary Purple Color from screenshot
  static const Color primaryPurple = Color(0xFF593A84);
  // Button Purple/Blue from design
  static const Color buttonPurple = Color(0xFF6B45F1);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF2EBE1); // The "Linen" color from design
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF022F40); // The "Indigo" color from design
  static const Color lightTextSecondary = Color(0x66022F40);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0A0F16);
  static const Color darkSurface = Color(0xFF161C26);
  static const Color darkText = Color(0xFFF2F5F7);
  static const Color darkTextSecondary = Color(0x99F2F5F7);
  
  // Accents (Indigo/Sapphire/Emerald from design)
  static const Color sapphire  = Color(0xFF0D6078);
  static const Color indigo    = Color(0xFF022F40);
  static const Color emerald   = Color(0xFF46C67D);
  static const Color brick     = Color(0xFFF9623E);
  static const Color sunflower = Color(0xFFF8C929);
  static const Color lavender  = Color(0xFF593A84);

  // Common Colors
  static const Color error = Color(0xFFF9623E);
  static const Color success = Color(0xFF46C67D);
  static const Color warning = Color(0xFFF8C929);
  
  // Theme-aware tokens
  static Color getBackgroundColor(BuildContext context) => Theme.of(context).colorScheme.background;
  static Color getSurfaceColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color getTextColor(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color getTextSecondary(BuildContext context) => Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

  static Color getPremiumText(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : indigo;
  static Color getPremiumTextSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.7) : indigo.withOpacity(0.6);
  static Color getMeshBaseColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F0F15) : const Color(0xFFF8F9FE);

  static Color getGlassColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
  }

  static Color getGlassBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);
  }

  // Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: sapphire,
      colorScheme: ColorScheme.light(
        primary: sapphire,
        secondary: lavender,
        surface: lightSurface,
        background: lightBackground,
        error: error,
        onPrimary: Colors.white,
        onSurface: lightText,
        onBackground: lightText,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sapphire,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
  
  // Get dark theme
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: sapphire,
      colorScheme: ColorScheme.dark(
        primary: sapphire,
        secondary: lavender,
        surface: darkSurface,
        background: darkBackground,
        error: error,
        onPrimary: Colors.white,
        onSurface: darkText,
        onBackground: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sapphire,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}
