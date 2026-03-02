import '../../../core/models/goal_difficulty.dart';

class PredefinedGoal {
  final String title;
  final GoalDifficulty difficulty;
  final int targetValue;
  final String? targetUnit;
  final int? initialValue;

  const PredefinedGoal({
    required this.title,
    required this.difficulty,
    required this.targetValue,
    this.targetUnit,
    this.initialValue,
  });
}

const List<PredefinedGoal> timeBasedGoals = [
  PredefinedGoal(title: '24h clean', difficulty: GoalDifficulty.easy, targetValue: 1, targetUnit: 'days'),
  PredefinedGoal(title: '3 days clean', difficulty: GoalDifficulty.easy, targetValue: 3, targetUnit: 'days'),
  PredefinedGoal(title: '7 days clean', difficulty: GoalDifficulty.medium, targetValue: 7, targetUnit: 'days'),
  PredefinedGoal(title: '30 days clean', difficulty: GoalDifficulty.hard, targetValue: 30, targetUnit: 'days'),
];

const List<PredefinedGoal> reductionGoals = [
  PredefinedGoal(title: '10 → 5 cigarettes', difficulty: GoalDifficulty.easy, targetValue: 5, targetUnit: 'cigarettes', initialValue: 10),
  PredefinedGoal(title: 'Screen time 6h → 3h', difficulty: GoalDifficulty.medium, targetValue: 3, targetUnit: 'hours', initialValue: 6),
  PredefinedGoal(title: 'Reduce sugar intake', difficulty: GoalDifficulty.medium, targetValue: 1, targetUnit: 'sessions', initialValue: 1),
];

const List<PredefinedGoal> alternativeGoals = [
  PredefinedGoal(title: '20 min sport', difficulty: GoalDifficulty.easy, targetValue: 1, targetUnit: 'sessions'),
  PredefinedGoal(title: 'Read 15 min instead', difficulty: GoalDifficulty.easy, targetValue: 1, targetUnit: 'sessions'),
  PredefinedGoal(title: 'Meditate 10 min', difficulty: GoalDifficulty.easy, targetValue: 1, targetUnit: 'sessions'),
];
