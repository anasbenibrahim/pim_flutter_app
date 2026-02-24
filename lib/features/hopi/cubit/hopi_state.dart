import 'package:flutter/material.dart';

/// Hopi's mood states — each maps to a visual theme, gradient, + character animation.
enum HopiMood {
  idle,     // Score 50–70 — calm, neutral, Hopi relaxed
  happy,    // Score > 70  — bright, warm, Hopi smiling
  anxious,  // Score 20–50 — tense, cool tones, Hopi worried
  sad,      // Score 5–20  — deep, subdued, Hopi down
  angry,    // Special — triggered by frustration patterns
}

/// Brand color constants from the HopeUp palette.
class HopiColors {
  HopiColors._();

  static const linen      = Color(0xFFF2EBE1);
  static const white      = Color(0xFFFFFFFF);
  static const sunflower  = Color(0xFFF8C929);
  static const sapphire   = Color(0xFF0D6078);
  static const emerald    = Color(0xFF46C67D);
  static const indigo     = Color(0xFF022F40);
  static const brick      = Color(0xFFF9623E);
  static const forest     = Color(0xFF0D9B76);
  static const teal       = Color(0xFF4ECDC4);
}

/// Gradient background for each mood state.
class HopiGradient {
  final Color top;
  final Color bottom;

  const HopiGradient({required this.top, required this.bottom});

  LinearGradient toLinearGradient() => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      );

  /// Idle: Linen → White
  static const idle = HopiGradient(
    top: HopiColors.linen,
    bottom: HopiColors.white,
  );

  /// Happy: Sunflower → Linen
  static const happy = HopiGradient(
    top: HopiColors.sunflower,
    bottom: HopiColors.linen,
  );

  /// Anxious: Sapphire → Emerald
  static const anxious = HopiGradient(
    top: HopiColors.sapphire,
    bottom: HopiColors.emerald,
  );

  /// Sad: Indigo → Sapphire
  static const sad = HopiGradient(
    top: HopiColors.indigo,
    bottom: HopiColors.sapphire,
  );

  /// Angry: Brick → Linen
  static const angry = HopiGradient(
    top: HopiColors.brick,
    bottom: HopiColors.linen,
  );

  static HopiGradient forMood(HopiMood mood) {
    switch (mood) {
      case HopiMood.idle:
        return idle;
      case HopiMood.happy:
        return happy;
      case HopiMood.anxious:
        return anxious;
      case HopiMood.sad:
        return sad;
      case HopiMood.angry:
        return angry;
    }
  }
}

/// Color palette for UI elements based on mood.
class HopiPalette {
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color cardColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  const HopiPalette({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.cardColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
  });

  /// Idle — warm neutrals, linen tones
  static const idle = HopiPalette(
    primary: HopiColors.sapphire,
    secondary: HopiColors.teal,
    surface: HopiColors.linen,
    background: HopiColors.white,
    cardColor: Color(0xFFFFFFFF),
    textPrimary: HopiColors.indigo,
    textSecondary: Color(0xFF5A7A8A),
    accent: HopiColors.forest,
  );

  /// Happy — bright, warm, golden
  static const happy = HopiPalette(
    primary: HopiColors.sunflower,
    secondary: HopiColors.forest,
    surface: Color(0xFFFFF8E7),
    background: HopiColors.linen,
    cardColor: Color(0xFFFFFFFF),
    textPrimary: HopiColors.indigo,
    textSecondary: Color(0xFF6B5A3D),
    accent: HopiColors.sunflower,
  );

  /// Anxious — deep teal to emerald
  static const anxious = HopiPalette(
    primary: HopiColors.emerald,
    secondary: HopiColors.sapphire,
    surface: Color(0xFFE0F5EA),
    background: Color(0xFFD0E8E0),
    cardColor: Color(0xE6FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xCCFFFFFF),
    accent: HopiColors.emerald,
  );

  /// Sad — deep indigo to sapphire
  static const sad = HopiPalette(
    primary: HopiColors.sapphire,
    secondary: Color(0xFF4A7B9D),
    surface: Color(0xFF0A4050),
    background: HopiColors.indigo,
    cardColor: Color(0x33FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xAAFFFFFF),
    accent: HopiColors.teal,
  );

  /// Angry — fiery brick to warm linen
  static const angry = HopiPalette(
    primary: HopiColors.brick,
    secondary: HopiColors.sunflower,
    surface: Color(0xFFFDE8E2),
    background: HopiColors.linen,
    cardColor: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF3D1510),
    textSecondary: Color(0xFF8A5A4A),
    accent: HopiColors.brick,
  );

  static HopiPalette forMood(HopiMood mood) {
    switch (mood) {
      case HopiMood.idle:
        return idle;
      case HopiMood.happy:
        return happy;
      case HopiMood.anxious:
        return anxious;
      case HopiMood.sad:
        return sad;
      case HopiMood.angry:
        return angry;
    }
  }
}

/// The full Hopi state — mood, score, gradient, and derived palette.
class HopiStateData {
  final double compositeScore;
  final HopiMood mood;
  final HopiPalette palette;
  final HopiGradient gradient;
  final String moodLabel;
  final String moodEmoji;

  HopiStateData({
    required this.compositeScore,
    required this.mood,
  })  : palette = HopiPalette.forMood(mood),
        gradient = HopiGradient.forMood(mood),
        moodLabel = _labelFor(mood),
        moodEmoji = _emojiFor(mood);

  /// Default initial state.
  factory HopiStateData.initial() => HopiStateData(
        compositeScore: 55.0,
        mood: HopiMood.idle,
      );

  /// Derive mood from a composite score (0–100).
  factory HopiStateData.fromScore(double score) {
    final HopiMood mood;
    if (score > 70) {
      mood = HopiMood.happy;
    } else if (score > 50) {
      mood = HopiMood.idle;
    } else if (score > 20) {
      mood = HopiMood.anxious;
    } else if (score > 5) {
      mood = HopiMood.sad;
    } else {
      mood = HopiMood.angry;
    }
    return HopiStateData(compositeScore: score, mood: mood);
  }

  static String _labelFor(HopiMood mood) {
    switch (mood) {
      case HopiMood.idle:
        return 'Calm';
      case HopiMood.happy:
        return 'Happy';
      case HopiMood.anxious:
        return 'Anxious';
      case HopiMood.sad:
        return 'Sad';
      case HopiMood.angry:
        return 'Angry';
    }
  }

  static String _emojiFor(HopiMood mood) {
    switch (mood) {
      case HopiMood.idle:
        return '😌';
      case HopiMood.happy:
        return '😊';
      case HopiMood.anxious:
        return '😟';
      case HopiMood.sad:
        return '😢';
      case HopiMood.angry:
        return '😠';
    }
  }

  /// Whether this is a dark mood (text should be light).
  bool get isDarkMood => mood == HopiMood.anxious || mood == HopiMood.sad;
}
