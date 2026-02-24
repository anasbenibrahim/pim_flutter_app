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

// ─── New Gamified Events ───

class UsernameChanged extends OnboardingEvent {
  final String username;
  const UsernameChanged(this.username);
  @override
  List<Object?> get props => [username];
}

class PrenamePrivacyToggled extends OnboardingEvent {
  const PrenamePrivacyToggled();
}

class HobbyToggled extends OnboardingEvent {
  final String hobby;
  const HobbyToggled(this.hobby);
  @override
  List<Object?> get props => [hobby];
}

class UsageDurationSelected extends OnboardingEvent {
  final String duration;
  const UsageDurationSelected(this.duration);
  @override
  List<Object?> get props => [duration];
}

class ReferralCodeChanged extends OnboardingEvent {
  final String code;
  const ReferralCodeChanged(this.code);
  @override
  List<Object?> get props => [code];
}

class EmailChanged extends OnboardingEvent {
  final String email;
  const EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends OnboardingEvent {
  final String password;
  const PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class NomChanged extends OnboardingEvent {
  final String nom;
  const NomChanged(this.nom);
  @override
  List<Object?> get props => [nom];
}

class PrenomChanged extends OnboardingEvent {
  final String prenom;
  const PrenomChanged(this.prenom);
  @override
  List<Object?> get props => [prenom];
}

class DateNaissanceChanged extends OnboardingEvent {
  final DateTime date;
  const DateNaissanceChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class ImagePathChanged extends OnboardingEvent {
  final String path;
  const ImagePathChanged(this.path);
  @override
  List<Object?> get props => [path];
}

class OnboardingSubmitted extends OnboardingEvent {}
