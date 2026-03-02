class GamificationModel {
  final int totalXp;
  final int level;
  final String levelTitle;
  final int xpToNextLevel;
  final double progressToNextLevel;
  final List<String> unlockedBadges;
  final String? motivationalMessage;

  GamificationModel({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpToNextLevel,
    required this.progressToNextLevel,
    this.unlockedBadges = const [],
    this.motivationalMessage,
  });

  factory GamificationModel.fromJson(Map<String, dynamic> json) {
    final badges = (json['unlockedBadges'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    return GamificationModel(
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      levelTitle: json['levelTitle'] as String? ?? 'Beginner',
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 50,
      progressToNextLevel: (json['progressToNextLevel'] as num?)?.toDouble() ?? 0.0,
      unlockedBadges: badges,
      motivationalMessage: json['motivationalMessage'] as String?,
    );
  }
}
