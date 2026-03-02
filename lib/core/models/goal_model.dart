import 'goal_category.dart';
import 'goal_difficulty.dart';
import 'goal_status.dart';

class GoalModel {
  final int id;
  final GoalCategory category;
  final String title;
  final GoalDifficulty difficulty;
  final int targetValue;
  final String? targetUnit;
  final int? initialValue;
  final int currentValue;
  final DateTime startDate;
  final DateTime? validatedAt;
  final String? validationNote;
  final GoalStatus status;
  final DateTime? createdAt;
  final int xpReward;
  final List<DateTime> checkInDates;

  GoalModel({
    required this.id,
    required this.category,
    required this.title,
    required this.difficulty,
    required this.targetValue,
    this.targetUnit,
    this.initialValue,
    required this.currentValue,
    required this.startDate,
    this.validatedAt,
    this.validationNote,
    required this.status,
    this.createdAt,
    required this.xpReward,
    this.checkInDates = const [],
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final checkInDates = (json['checkInDates'] as List<dynamic>?)
            ?.map((e) => DateTime.parse(e as String))
            .toList() ??
        [];
    return GoalModel(
      id: json['id'] as int,
      category: GoalCategory.fromString(json['category'] as String? ?? ''),
      title: json['title'] as String,
      difficulty: GoalDifficulty.fromString(json['difficulty'] as String? ?? ''),
      targetValue: json['targetValue'] as int,
      targetUnit: json['targetUnit'] as String?,
      initialValue: json['initialValue'] as int?,
      currentValue: json['currentValue'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      validatedAt: json['validatedAt'] != null
          ? DateTime.parse(json['validatedAt'] as String)
          : null,
      validationNote: json['validationNote'] as String?,
      status: GoalStatus.fromString(json['status'] as String? ?? ''),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      xpReward: json['xpReward'] as int? ?? 10,
      checkInDates: checkInDates,
    );
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  /// For time-based: backend sets currentValue from days. For others: from check-ins.
  bool get canValidate => status == GoalStatus.inProgress && currentValue >= targetValue;
}
