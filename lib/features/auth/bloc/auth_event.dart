import 'package:equatable/equatable.dart';
import '../../../core/models/addiction_type.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  const LoginEvent({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class RegisterPatientEvent extends AuthEvent {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final int age;
  final DateTime dateNaissance;
  final DateTime? sobrietyDate;
  final AddictionType? addiction;
  final String? imagePath;
  
  // Gamified Onboarding Fields
  final String? username;
  final bool prenamePrivate;
  final String? usageDuration;
  final List<String> hobbies;
  final List<String> triggers;
  final List<String> copingMechanisms;
  final List<String> motivations;
  
  const RegisterPatientEvent({
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.age,
    required this.dateNaissance,
    this.sobrietyDate,
    this.addiction,
    this.imagePath,
    this.username,
    this.prenamePrivate = false,
    this.usageDuration,
    this.hobbies = const [],
    this.triggers = const [],
    this.copingMechanisms = const [],
    this.motivations = const [],
  });
  
  @override
  List<Object?> get props => [
    email,
    password,
    nom,
    prenom,
    age,
    dateNaissance,
    sobrietyDate,
    addiction,
    imagePath,
    username,
    prenamePrivate,
    usageDuration,
    hobbies,
    triggers,
    copingMechanisms,
    motivations,
  ];
}

class RegisterVolontaireEvent extends AuthEvent {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final int age;
  final String? imagePath;
  
  const RegisterVolontaireEvent({
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.age,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [email, password, nom, prenom, age, imagePath];
}

class RegisterFamilyMemberEvent extends AuthEvent {
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final String referralKey;
  final String? imagePath;
  
  const RegisterFamilyMemberEvent({
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.referralKey,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [email, password, nom, prenom, referralKey, imagePath];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();
}

class AppleSignInEvent extends AuthEvent {
  const AppleSignInEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  
  const ForgotPasswordEvent({required this.email});
  
  @override
  List<Object?> get props => [email];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otpCode;
  
  const VerifyOtpEvent({required this.email, required this.otpCode});
  
  @override
  List<Object?> get props => [email, otpCode];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otpCode;
  final String newPassword;
  final String confirmPassword;
  
  const ResetPasswordEvent({
    required this.email,
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });
  
  @override
  List<Object?> get props => [email, otpCode, newPassword, confirmPassword];
}

class UpdatePatientProfileEvent extends AuthEvent {
  final String nom;
  final String prenom;
  final int age;
  final String? imagePath;
  
  const UpdatePatientProfileEvent({
    required this.nom,
    required this.prenom,
    required this.age,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [nom, prenom, age, imagePath];
}

class UpdateVolontaireProfileEvent extends AuthEvent {
  final String nom;
  final String prenom;
  final int age;
  final String? imagePath;
  
  const UpdateVolontaireProfileEvent({
    required this.nom,
    required this.prenom,
    required this.age,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [nom, prenom, age, imagePath];
}

class UpdateFamilyMemberProfileEvent extends AuthEvent {
  final String nom;
  final String prenom;
  final String? imagePath;
  
  const UpdateFamilyMemberProfileEvent({
    required this.nom,
    required this.prenom,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [nom, prenom, imagePath];
}

class VerifyRegistrationOtpEvent extends AuthEvent {
  final String email;
  final String otpCode;
  final String userRole;
  final String? imagePath;
  
  const VerifyRegistrationOtpEvent({
    required this.email,
    required this.otpCode,
    required this.userRole,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [email, otpCode, userRole, imagePath];
}
