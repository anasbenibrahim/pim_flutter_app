import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  
  AuthBloc({required this.apiService}) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterPatientEvent>(_onRegisterPatient);
    on<RegisterVolontaireEvent>(_onRegisterVolontaire);
    on<RegisterFamilyMemberEvent>(_onRegisterFamilyMember);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<AppleSignInEvent>(_onAppleSignIn);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdatePatientProfileEvent>(_onUpdatePatientProfile);
    on<UpdateVolontaireProfileEvent>(_onUpdateVolontaireProfile);
    on<UpdateFamilyMemberProfileEvent>(_onUpdateFamilyMemberProfile);
    on<VerifyRegistrationOtpEvent>(_onVerifyRegistrationOtp);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await apiService.login(event.email, event.password);
      final user = await apiService.getCurrentUser();
      _emitAuthenticated(user, emit);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _emitAuthenticated(UserModel user, Emitter<AuthState> emit) {
    if (user.role == UserRole.patient && !user.hasCompletedOnboarding) {
      emit(AuthOnboardingRequired(user: user));
    } else {
      emit(AuthAuthenticated(user: user));
    }
  }
  
  Future<void> _onRegisterPatient(
    RegisterPatientEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await apiService.registerPatient(
        email: event.email,
        password: event.password,
        nom: event.nom,
        prenom: event.prenom,
        age: event.age,
        dateNaissance: event.dateNaissance,
        sobrietyDate: event.sobrietyDate,
        addiction: event.addiction?.value,
        imagePath: event.imagePath,
      );
      // Emit OTP sent state with registration data
      emit(RegistrationOtpSentState(
        email: event.email,
        userRole: 'PATIENT',
        registrationData: {
          'email': event.email,
          'password': event.password,
          'nom': event.nom,
          'prenom': event.prenom,
          'age': event.age,
          'dateNaissance': event.dateNaissance.toIso8601String().split('T')[0],
          'sobrietyDate': event.sobrietyDate?.toIso8601String().split('T')[0],
          'addiction': event.addiction?.value,
        },
        imagePath: event.imagePath,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onRegisterVolontaire(
    RegisterVolontaireEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await apiService.registerVolontaire(
        email: event.email,
        password: event.password,
        nom: event.nom,
        prenom: event.prenom,
        age: event.age,
        imagePath: event.imagePath,
      );
      // Emit OTP sent state with registration data
      emit(RegistrationOtpSentState(
        email: event.email,
        userRole: 'VOLONTAIRE',
        registrationData: {
          'email': event.email,
          'password': event.password,
          'nom': event.nom,
          'prenom': event.prenom,
          'age': event.age,
        },
        imagePath: event.imagePath,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onRegisterFamilyMember(
    RegisterFamilyMemberEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await apiService.registerFamilyMember(
        email: event.email,
        password: event.password,
        nom: event.nom,
        prenom: event.prenom,
        referralKey: event.referralKey,
        imagePath: event.imagePath,
      );
      // Emit OTP sent state with registration data
      emit(RegistrationOtpSentState(
        email: event.email,
        userRole: 'FAMILY_MEMBER',
        registrationData: {
          'email': event.email,
          'password': event.password,
          'nom': event.nom,
          'prenom': event.prenom,
          'referralKey': event.referralKey,
        },
        imagePath: event.imagePath,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await apiService.clearTokens();
    emit(const AuthUnauthenticated());
  }
  
  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await apiService.getCurrentUser();
      _emitAuthenticated(user, emit);
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
  
  Future<void> _onGoogleSignIn(GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        await googleUser.authentication;
        // For now, we'll just show an error that backend integration is needed
        emit(const AuthError(message: 'Google Sign-In: Backend integration needed'));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Google Sign-In failed: ${e.toString()}'));
    }
  }
  
  Future<void> _onAppleSignIn(AppleSignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      

      emit(const AuthError(message: 'Apple Sign-In: Backend integration needed'));
    } catch (e) {
      if (e.toString().contains('CANCELLED')) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthError(message: 'Apple Sign-In failed: ${e.toString()}'));
      }
    }
  }
  
  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await apiService.forgotPassword(event.email);
      emit(OtpSentState(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await apiService.verifyOtp(event.email, event.otpCode);
      emit(OtpVerifiedState(email: event.email, otpCode: event.otpCode));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      if (event.newPassword != event.confirmPassword) {
        emit(const AuthError(message: 'Passwords do not match'));
        return;
      }
      await apiService.resetPassword(event.email, event.otpCode, event.newPassword, event.confirmPassword);
      emit(const PasswordResetSuccessState());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdatePatientProfile(
    UpdatePatientProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await apiService.updatePatientProfile(
        nom: event.nom,
        prenom: event.prenom,
        age: event.age,
        imagePath: event.imagePath,
      );
      _emitAuthenticated(user, emit);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdateVolontaireProfile(
    UpdateVolontaireProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await apiService.updateVolontaireProfile(
        nom: event.nom,
        prenom: event.prenom,
        age: event.age,
        imagePath: event.imagePath,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdateFamilyMemberProfile(
    UpdateFamilyMemberProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await apiService.updateFamilyMemberProfile(
        nom: event.nom,
        prenom: event.prenom,
        imagePath: event.imagePath,
      );
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onVerifyRegistrationOtp(
    VerifyRegistrationOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await apiService.verifyRegistrationOtp(
        email: event.email,
        otpCode: event.otpCode,
        userRole: event.userRole,
        imagePath: event.imagePath,
      );
      final user = await apiService.getCurrentUser();
      _emitAuthenticated(user, emit);
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
