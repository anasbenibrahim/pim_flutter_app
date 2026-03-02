import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/gamification_model.dart';
import 'goals_event.dart';
import 'goals_state.dart';

class GoalsBloc extends Bloc<GoalsEvent, GoalsState> {
  final ApiService apiService;

  GoalsBloc({required this.apiService}) : super(GoalsInitial()) {
    on<LoadGoalsEvent>(_onLoadGoals);
    on<CreateGoalEvent>(_onCreateGoal);
    on<LoadGoalEvent>(_onLoadGoal);
    on<AddCheckInEvent>(_onAddCheckIn);
    on<ValidateGoalEvent>(_onValidateGoal);
  }

  Future<void> _onLoadGoals(LoadGoalsEvent event, Emitter<GoalsState> emit) async {
    emit(GoalsLoading());
    try {
      final goals = await apiService.getGoals();
      GamificationModel? gamification;
      try {
        gamification = await apiService.getGamification();
      } catch (_) {}
      emit(GoalsLoaded(goals: goals, gamification: gamification));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateGoal(CreateGoalEvent event, Emitter<GoalsState> emit) async {
    emit(GoalsLoading());
    try {
      await apiService.createGoal(
        category: event.category,
        title: event.title,
        difficulty: event.difficulty,
        targetValue: event.targetValue,
        targetUnit: event.targetUnit,
        initialValue: event.initialValue,
      );
      final goals = await apiService.getGoals();
      GamificationModel? gamification;
      try {
        gamification = await apiService.getGamification();
      } catch (_) {}
      emit(GoalCreated(goals: goals, gamification: gamification));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadGoal(LoadGoalEvent event, Emitter<GoalsState> emit) async {
    emit(GoalsLoading());
    try {
      final goal = await apiService.getGoal(event.goalId);
      emit(GoalDetailLoaded(goal));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddCheckIn(AddCheckInEvent event, Emitter<GoalsState> emit) async {
    try {
      final goal = await apiService.addGoalCheckIn(event.goalId, date: event.date);
      emit(GoalDetailLoaded(goal));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onValidateGoal(ValidateGoalEvent event, Emitter<GoalsState> emit) async {
    try {
      final gamification = await apiService.validateGoal(event.goalId, note: event.note);
      emit(GoalValidated(gamification));
    } catch (e) {
      emit(GoalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
