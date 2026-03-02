import 'package:flutter/material.dart';
import '../../features/auth/pages/get_started_page.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/role_selection_page.dart';
import '../../features/auth/pages/register_patient_simple_page.dart';
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
import '../../features/onboarding/pages/onboarding_wrapper_page.dart';
import '../../features/welcome/pages/welcome_carousel_page.dart';
import '../../features/assessment/assessment_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/social/data/models/post_model.dart';
import '../../features/social/presentation/pages/social_feed_page.dart';
import '../../features/social/presentation/pages/create_post_page.dart';
import '../../features/social/presentation/pages/post_detail_page.dart';

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
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String assessment = '/assessment';
  static const String notifications = '/notifications';
  
  // Social routes
  static const String socialFeed = '/social-feed';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeCarouselPage());

      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedPage());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionPage());
      
      case registerPatient:
        return MaterialPageRoute(builder: (_) => const RegisterPatientSimplePage());
      
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

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingWrapperPage());

      case assessment:
        return MaterialPageRoute(builder: (_) => const AssessmentPage());
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      
      case socialFeed:
        return MaterialPageRoute(builder: (_) => const SocialFeedPage());
        
      case createPost:
        return MaterialPageRoute(builder: (_) => const CreatePostPage());
        
      case postDetail:
        final post = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => PostDetailPage(
            postId: post is PostModel ? post.id : post as int,
            initialPost: post is PostModel ? post : null,
          ),
        );

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
