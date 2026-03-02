import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final ApiService apiService;

  OnboardingBloc({required this.apiService}) : super(const OnboardingState()) {
    on<RegionSelected>((event, emit) {
      emit(state.copyWith(region: event.region));
    });

    on<ActivityStatusSelected>((event, emit) {
      emit(state.copyWith(activityStatus: event.status));
    });

    on<LifeRhythmSelected>((event, emit) {
      emit(state.copyWith(lifeRhythm: event.rhythm));
    });

    on<SobrietyDateSelected>((event, emit) {
      emit(state.copyWith(sobrietyDate: event.date));
    });

    on<SubstanceSelected>((event, emit) {
      emit(state.copyWith(substance: event.substance));
    });

    on<GoalSelected>((event, emit) {
      emit(state.copyWith(goal: event.goal));
    });

    on<TriggerToggled>((event, emit) {
      final updatedTriggers = List<String>.from(state.triggers);
      if (updatedTriggers.contains(event.trigger)) {
        updatedTriggers.remove(event.trigger);
      } else {
        updatedTriggers.add(event.trigger);
      }
      emit(state.copyWith(triggers: updatedTriggers));
    });

    on<CopingMechanismToggled>((event, emit) {
      final updatedData = List<String>.from(state.copingMechanisms);
      if (updatedData.contains(event.mechanism)) {
        updatedData.remove(event.mechanism);
      } else {
        updatedData.add(event.mechanism);
      }
      emit(state.copyWith(copingMechanisms: updatedData));
    });

    on<MotivationToggled>((event, emit) {
      final updatedData = List<String>.from(state.motivations);
      if (updatedData.contains(event.motivation)) {
        updatedData.remove(event.motivation);
      } else {
        updatedData.add(event.motivation);
      }
      emit(state.copyWith(motivations: updatedData));
    });

    on<OnboardingSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      print('DEBUG: Sending onboarding data...');
      print('DEBUG: Region: ${state.region}');
      print('DEBUG: Addiction: ${state.substance}');
      
      await apiService.completeOnboarding(
        sobrietyDate: state.sobrietyDate,
        substance: state.substance,
        lifeRhythm: state.lifeRhythm,
        activityStatus: state.activityStatus,
        region: state.region,
        triggers: state.triggers,
        copingMechanisms: state.copingMechanisms,
        motivations: state.motivations,
      );
      
      print('DEBUG: Onboarding submission SUCCESS');
      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      print('DEBUG: Onboarding submission FAILED: $e');
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
