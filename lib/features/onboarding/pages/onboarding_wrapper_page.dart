import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../bloc/onboarding_event.dart';
import 'step1_welcome_page.dart';
import 'step5_safecircle_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';

const _linen   = Color(0xFFF2EBE1);
const _emerald = Color(0xFF46C67D);
const _brick   = Color(0xFFF9623E);

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
      duration: const Duration(milliseconds: 350),
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
              SnackBar(
                content: const Text('Finalisation de votre profil...'),
                backgroundColor: _emerald,
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state.status == OnboardingStatus.success) {
            context.read<AuthBloc>().add(const CheckAuthEvent());
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.mainNavigation,
              (route) => false,
            );
          } else if (state.status == OnboardingStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Une erreur est survenue'),
                backgroundColor: _brick,
              ),
            );
          }
        },
        child: Builder(
          builder: (builderContext) => Scaffold(
            backgroundColor: _linen,
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Welcome
                WelcomePage(onNext: _nextPage),
                // Step 2: SafeCircle (skip duplicate data steps since registration already collected them)
                SafeCirclePage(onFinish: () {
                  builderContext.read<OnboardingBloc>().add(OnboardingSubmitted());
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
