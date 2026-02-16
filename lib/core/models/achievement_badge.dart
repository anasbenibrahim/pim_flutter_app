enum AchievementBadge {
  champion,   // Meilleur - sobriété + humeur positive
  courageux,  // Moyen - sobriété + humeur anxieuse
  rebond,     // À améliorer
}

extension AchievementBadgeExtension on AchievementBadge {
  String get label {
    switch (this) {
      case AchievementBadge.champion:
        return 'Champion';
      case AchievementBadge.courageux:
        return 'Courageous';
      case AchievementBadge.rebond:
        return 'Bounce Back';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementBadge.champion:
        return '🏆';
      case AchievementBadge.courageux:
        return '💪';
      case AchievementBadge.rebond:
        return '🔄';
    }
  }

  /// Asset path for badge icon: 1=good, 2=medium, 3=bad
  String get assetPath {
    switch (this) {
      case AchievementBadge.champion:
        return 'assets/images/1.png';
      case AchievementBadge.courageux:
        return 'assets/images/2.png';
      case AchievementBadge.rebond:
        return 'assets/images/3.png';
    }
  }

  /// English description for the badge (used to ensure consistent English display)
  String get description {
    switch (this) {
      case AchievementBadge.champion:
        return 'Great week! 4+ days abstinent with a positive mood.';
      case AchievementBadge.courageux:
        return "4+ days abstinent despite anxiety. You're making progress!";
      case AchievementBadge.rebond:
        return '4+ days with consumption or low mood. Every day is a new chance.';
    }
  }
}


AchievementBadge achievementBadgeFromString(String value) {
  return AchievementBadge.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => AchievementBadge.rebond,
  );
}
