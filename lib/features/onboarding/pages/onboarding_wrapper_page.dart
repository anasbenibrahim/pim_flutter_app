import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../bloc/onboarding_event.dart';
import 'step1_welcome_page.dart';
import 'step2_corner_page.dart';
import 'step3_goal_page.dart';
import 'step4_strengths_page.dart';
import 'step5_safecircle_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/premium_widgets.dart';

class OnboardingWrapperPage extends StatefulWidget {
  const OnboardingWrapperPage({super.key});

  @override
  State<OnboardingWrapperPage> createState() => _OnboardingWrapperPageState();
}

class _OnboardingWrapperPageState extends State<OnboardingWrapperPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(apiService: ApiService()),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state.status == OnboardingStatus.loading) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Finalisation de votre profil...'),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state.status == OnboardingStatus.success) {
            // Refresh user profile in AuthBloc
            context.read<AuthBloc>().add(const CheckAuthEvent());
            
            // Navigate to Main Navigation
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.mainNavigation, 
              (route) => false,
            );
          } else if (state.status == OnboardingStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Une erreur est survenue'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Builder(
          builder: (builderContext) => Scaffold(
            backgroundColor: Colors.transparent,
            body: MeshGradientBackground(
              child: SafeArea(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WelcomePage(onNext: _nextPage),
                    CornerPage(onNext: _nextPage),
                    GoalPage(onNext: _nextPage),
                    StrengthsPage(onNext: _nextPage),
                    SafeCirclePage(onFinish: () {
                       builderContext.read<OnboardingBloc>().add(OnboardingSubmitted());
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
