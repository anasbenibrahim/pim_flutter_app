import '../../../core/models/goal_model.dart';
import '../../../core/models/gamification_model.dart';

abstract class GoalsState {}

class GoalsInitial extends GoalsState {}

class GoalsLoading extends GoalsState {}

class GoalCreated extends GoalsState {
  /// Emitted only when a goal is successfully created (not on back/cancel).
  final List<GoalModel> goals;
  final GamificationModel? gamification;

  GoalCreated({required this.goals, this.gamification});
}

class GoalsLoaded extends GoalsState {
  final List<GoalModel> goals;
  final GamificationModel? gamification;

  GoalsLoaded({
    required this.goals,
    this.gamification,
  });
}

class GoalDetailLoaded extends GoalsState {
  final GoalModel goal;

  GoalDetailLoaded(this.goal);
}

class GoalValidated extends GoalsState {
  final GamificationModel gamification;

  GoalValidated(this.gamification);
}

class GoalsError extends GoalsState {
  final String message;

  GoalsError(this.message);
}
