import '../../../core/models/goal_category.dart';
import '../../../core/models/goal_difficulty.dart';

abstract class GoalsEvent {
  const GoalsEvent();
}

class LoadGoalsEvent extends GoalsEvent {
  const LoadGoalsEvent();
}

class CreateGoalEvent extends GoalsEvent {
  final GoalCategory category;
  final String title;
  final GoalDifficulty difficulty;
  final int targetValue;
  final String? targetUnit;
  final int? initialValue;

  CreateGoalEvent({
    required this.category,
    required this.title,
    required this.difficulty,
    required this.targetValue,
    this.targetUnit,
    this.initialValue,
  });
}

class LoadGoalEvent extends GoalsEvent {
  final int goalId;

  LoadGoalEvent(this.goalId);
}

class AddCheckInEvent extends GoalsEvent {
  final int goalId;
  final DateTime? date;

  AddCheckInEvent(this.goalId, [this.date]);
}

class ValidateGoalEvent extends GoalsEvent {
  final int goalId;
  final String? note;

  ValidateGoalEvent(this.goalId, [this.note]);
}
