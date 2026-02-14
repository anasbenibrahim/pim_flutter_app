import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingStarted extends OnboardingEvent {}

class RegionSelected extends OnboardingEvent {
  final String region;
  const RegionSelected(this.region);
  @override
  List<Object?> get props => [region];
}

class ActivityStatusSelected extends OnboardingEvent {
  final String status;
  const ActivityStatusSelected(this.status);
  @override
  List<Object?> get props => [status];
}

class LifeRhythmSelected extends OnboardingEvent {
  final String rhythm;
  const LifeRhythmSelected(this.rhythm);
  @override
  List<Object?> get props => [rhythm];
}

class SobrietyDateSelected extends OnboardingEvent {
  final DateTime date;
  const SobrietyDateSelected(this.date);
  @override
  List<Object?> get props => [date];
}

class SubstanceSelected extends OnboardingEvent {
  final String substance;
  const SubstanceSelected(this.substance);
  @override
  List<Object?> get props => [substance];
}

class GoalSelected extends OnboardingEvent {
  final String goal;
  const GoalSelected(this.goal);
  @override
  List<Object?> get props => [goal];
}

class TriggerToggled extends OnboardingEvent {
  final String trigger;
  const TriggerToggled(this.trigger);
  @override
  List<Object?> get props => [trigger];
}

class CopingMechanismToggled extends OnboardingEvent {
  final String mechanism;
  const CopingMechanismToggled(this.mechanism);
  @override
  List<Object?> get props => [mechanism];
}

class MotivationToggled extends OnboardingEvent {
  final String motivation;
  const MotivationToggled(this.motivation);
  @override
  List<Object?> get props => [motivation];
}

class OnboardingSubmitted extends OnboardingEvent {}
