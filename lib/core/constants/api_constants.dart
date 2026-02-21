import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  // Platform-aware base URL
  // For Android emulator: use 10.0.2.2 (special IP that maps to host machine's localhost)
  // For iOS simulator: use localhost
  // For physical devices: use your computer's IP address (e.g., 192.168.1.100)
  // You can override this by setting the API_BASE_URL environment variable
  
  static String get baseUrl {
    // Check for environment variable override
    const String envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Platform-specific URLs
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Use your computer's local IP for physical devices and emulators
      // 10.0.2.2 only works for emulators. 192.168.1.16 is your PC's IP.
      return 'http://192.168.1.16:8080/api';
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS simulator can use localhost
      return 'http://localhost:8080/api';
    } else {
      // Default for other platforms (web, desktop, etc.)
      return 'http://localhost:8080/api';
    }
  }
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String registerPatient = '/auth/register/patient';
  static const String registerVolontaire = '/auth/register/volontaire';
  static const String registerFamily = '/auth/register/family';
  static const String refreshToken = '/auth/refresh';
  static const String getCurrentUser = '/auth/me';
  
  // Password reset endpoints
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  
  // Registration OTP endpoints
  static const String verifyRegistrationOtp = '/auth/verify-registration-otp';
  
  // Profile update endpoints
  static const String updatePatientProfile = '/auth/profile/patient';
  static const String updateVolontaireProfile = '/auth/profile/volontaire';
  static const String updateFamilyMemberProfile = '/auth/profile/family';
  // Onboarding endpoints
  static const String completeOnboarding = '/v1/onboarding/complete';
  static const String completeAssessment = '/v1/onboarding/assessment';
}
