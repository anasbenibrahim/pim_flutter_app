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

    // ─── New Gamified Handlers ───

    on<EmailChanged>((event, emit) {
      emit(state.copyWith(email: event.email));
    });

    on<PasswordChanged>((event, emit) {
      emit(state.copyWith(password: event.password));
    });

    on<NomChanged>((event, emit) {
      emit(state.copyWith(nom: event.nom));
    });

    on<PrenomChanged>((event, emit) {
      emit(state.copyWith(prenom: event.prenom));
    });

    on<DateNaissanceChanged>((event, emit) {
      emit(state.copyWith(dateNaissance: event.date));
    });

    on<ImagePathChanged>((event, emit) {
      emit(state.copyWith(imagePath: event.path));
    });

    on<UsernameChanged>((event, emit) {
      emit(state.copyWith(username: event.username));
    });

    on<PrenamePrivacyToggled>((event, emit) {
      emit(state.copyWith(prenamePrivate: !state.prenamePrivate));
    });

    on<HobbyToggled>((event, emit) {
      final updated = List<String>.from(state.hobbies);
      if (updated.contains(event.hobby)) {
        updated.remove(event.hobby);
      } else {
        updated.add(event.hobby);
      }
      emit(state.copyWith(hobbies: updated));
    });

    on<UsageDurationSelected>((event, emit) {
      emit(state.copyWith(usageDuration: event.duration));
    });

    on<ReferralCodeChanged>((event, emit) {
      emit(state.copyWith(referralCode: event.code));
    });

    on<OnboardingSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    OnboardingSubmitted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      await apiService.completeOnboarding(
        sobrietyDate: state.sobrietyDate,
        substance: state.substance,
        lifeRhythm: state.lifeRhythm,
        activityStatus: state.activityStatus,
        region: state.region,
        triggers: state.triggers,
        copingMechanisms: state.copingMechanisms,
        motivations: state.motivations,
        username: state.username,
        prenamePrivate: state.prenamePrivate,
        usageDuration: state.usageDuration,
        hobbies: state.hobbies,
      );
      
      emit(state.copyWith(status: OnboardingStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
