import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class OtpSentState extends AuthState {
  final String email;
  
  const OtpSentState({required this.email});
  
  @override
  List<Object?> get props => [email];
}

class OtpVerifiedState extends AuthState {
  final String email;
  final String otpCode;
  
  const OtpVerifiedState({required this.email, required this.otpCode});
  
  @override
  List<Object?> get props => [email, otpCode];
}

class PasswordResetSuccessState extends AuthState {
  const PasswordResetSuccessState();
}

class RegistrationOtpSentState extends AuthState {
  final String email;
  final String userRole;
  final Map<String, dynamic> registrationData;
  final String? imagePath;
  
  const RegistrationOtpSentState({
    required this.email,
    required this.userRole,
    required this.registrationData,
    this.imagePath,
  });
  
  @override
  List<Object?> get props => [email, userRole, registrationData, imagePath];
}
