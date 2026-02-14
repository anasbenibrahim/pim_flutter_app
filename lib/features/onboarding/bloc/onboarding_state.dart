import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, loading, success, failure }

class OnboardingState extends Equatable {
  final OnboardingStatus status;
  final String? errorMessage;
  
  // Data Fields
  final String? region;
  final String? activityStatus;
  final String? lifeRhythm;
  final DateTime? sobrietyDate;
  final String? substance;
  final String? goal;
  final List<String> triggers;
  final List<String> copingMechanisms;
  final List<String> motivations;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.errorMessage,
    this.region,
    this.activityStatus,
    this.lifeRhythm,
    this.sobrietyDate,
    this.substance,
    this.goal,
    this.triggers = const [],
    this.copingMechanisms = const [],
    this.motivations = const [],
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? errorMessage,
    String? region,
    String? activityStatus,
    String? lifeRhythm,
    DateTime? sobrietyDate,
    String? substance,
    String? goal,
    List<String>? triggers,
    List<String>? copingMechanisms,
    List<String>? motivations,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      region: region ?? this.region,
      activityStatus: activityStatus ?? this.activityStatus,
      lifeRhythm: lifeRhythm ?? this.lifeRhythm,
      sobrietyDate: sobrietyDate ?? this.sobrietyDate,
      substance: substance ?? this.substance,
      goal: goal ?? this.goal,
      triggers: triggers ?? this.triggers,
      copingMechanisms: copingMechanisms ?? this.copingMechanisms,
      motivations: motivations ?? this.motivations,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        region,
        activityStatus,
        lifeRhythm,
        sobrietyDate,
        substance,
        goal,
        triggers,
        copingMechanisms,
        motivations,
      ];
}
