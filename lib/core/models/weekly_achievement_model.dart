import 'achievement_badge.dart' show AchievementBadge, achievementBadgeFromString;

class WeeklyAchievementModel {
  final AchievementBadge badge;
  final String badgeLabel;
  final String badgeDescription;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int abstinentDays;
  final int consumedDays;
  final int totalDaysWithData;

  WeeklyAchievementModel({
    required this.badge,
    required this.badgeLabel,
    required this.badgeDescription,
    required this.weekStart,
    required this.weekEnd,
    required this.abstinentDays,
    required this.consumedDays,
    required this.totalDaysWithData,
  });

  factory WeeklyAchievementModel.fromJson(Map<String, dynamic> json) {
    return WeeklyAchievementModel(
      badge: achievementBadgeFromString(json['badge'] as String),
      badgeLabel: json['badgeLabel'] as String,
      badgeDescription: json['badgeDescription'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      abstinentDays: json['abstinentDays'] as int,
      consumedDays: json['consumedDays'] as int,
      totalDaysWithData: json['totalDaysWithData'] as int,
    );
  }
}
