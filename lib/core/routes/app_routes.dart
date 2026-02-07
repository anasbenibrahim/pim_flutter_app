import 'package:flutter/material.dart';
import '../../features/auth/pages/get_started_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/role_selection_page.dart';
import '../../features/auth/pages/register_patient_page.dart';
import '../../features/auth/pages/register_volontaire_page.dart';
import '../../features/auth/pages/register_family_page.dart';
import '../../features/auth/pages/forgot_password_page.dart';
import '../../features/auth/pages/otp_verification_page.dart';
import '../../features/auth/pages/register_otp_verification_page.dart';
import '../../features/auth/pages/reset_password_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/update_profile_page.dart';
import '../../features/navigation/pages/main_navigation_page.dart';

class AppRoutes {
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String registerPatient = '/register-patient';
  static const String registerVolontaire = '/register-volontaire';
  static const String registerFamily = '/register-family';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String registerOtpVerification = '/register-otp-verification';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String mainNavigation = '/main-navigation';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedPage());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionPage());
      
      case registerPatient:
        return MaterialPageRoute(builder: (_) => const RegisterPatientPage());
      
      case registerVolontaire:
        return MaterialPageRoute(builder: (_) => const RegisterVolontairePage());
      
      case registerFamily:
        return MaterialPageRoute(builder: (_) => const RegisterFamilyPage());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      
      case otpVerification:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(email: email),
        );
      
      case registerOtpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RegisterOtpVerificationPage(
            email: args?['email'] ?? '',
            userRole: args?['userRole'] ?? '',
            imagePath: args?['imagePath'],
          ),
        );
      
      case resetPassword:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            email: args?['email'] ?? '',
            otpCode: args?['otpCode'] ?? '',
          ),
        );
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      
      case updateProfile:
        return MaterialPageRoute(
          builder: (_) => const UpdateProfilePage(),
          settings: settings,
        );
      
      case mainNavigation:
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
