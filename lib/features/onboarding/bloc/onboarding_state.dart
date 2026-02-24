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

  // New gamified fields
  final String? username;
  final bool prenamePrivate;
  final List<String> hobbies;
  final String? usageDuration;
  final String? referralCode;

  // Registration fields
  final String? email;
  final String? password;
  final String? nom;
  final String? prenom;
  final DateTime? dateNaissance;
  final String? imagePath;

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
    this.username,
    this.prenamePrivate = false,
    this.hobbies = const [],
    this.usageDuration,
    this.referralCode,
    this.email,
    this.password,
    this.nom,
    this.prenom,
    this.dateNaissance,
    this.imagePath,
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
    String? username,
    bool? prenamePrivate,
    List<String>? hobbies,
    String? usageDuration,
    String? referralCode,
    String? email,
    String? password,
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    String? imagePath,
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
      username: username ?? this.username,
      prenamePrivate: prenamePrivate ?? this.prenamePrivate,
      hobbies: hobbies ?? this.hobbies,
      usageDuration: usageDuration ?? this.usageDuration,
      referralCode: referralCode ?? this.referralCode,
      email: email ?? this.email,
      password: password ?? this.password,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      imagePath: imagePath ?? this.imagePath,
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
        username,
        prenamePrivate,
        hobbies,
        usageDuration,
        referralCode,
        email,
        password,
        nom,
        prenom,
        dateNaissance,
        imagePath,
      ];
}
