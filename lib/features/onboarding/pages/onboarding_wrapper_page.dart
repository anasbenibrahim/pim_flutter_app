import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../bloc/onboarding_event.dart';
import 'page1_identity.dart';
import 'page2_hobbies.dart';
import 'page3_safe_space.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/addiction_type.dart';

const _forestGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFB5DDE6), // Light sapphire tint
    Color(0xFF5BA8B8), // Mid sapphire
    Color(0xFF0D6078), // Sapphire
    Color(0xFF053545), // Transition
    Color(0xFF022F40), // Indigo
  ],
  stops: [0.0, 0.2, 0.45, 0.75, 1.0],
);

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

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(apiService: ApiService()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Création de votre compte...'),
                backgroundColor: _emerald,
                duration: Duration(seconds: 1),
              ),
            );
          } else if (authState is RegistrationOtpSentState) {
            Navigator.pushNamed(
              context,
              AppRoutes.registerOtpVerification,
              arguments: {
                'email': authState.email,
                'userRole': authState.userRole,
                'imagePath': authState.imagePath,
              },
            );
          } else if (authState is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
                backgroundColor: _brick,
              ),
            );
          }
        },
        child: Builder(
          builder: (builderContext) => Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: const BoxDecoration(gradient: _forestGradient),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Page 1: Identity & Privacy
                  Page1Identity(onNext: _nextPage),
                  // Page 2: Hobby Garden
                  Page2Hobbies(onNext: _nextPage),
                  // Page 3: Safe Space (confidential recovery data)
                  Page3SafeSpace(onFinish: () {
                    final state = builderContext.read<OnboardingBloc>().state;
                    if (state.email == null || state.password == null || state.dateNaissance == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez remplir toutes les informations à la première étape.')),
                      );
                      _pageController.jumpToPage(0);
                      return;
                    }

                    AddictionType? addictionType;
                    if (state.substance != null) {
                      try {
                        addictionType = AddictionType.values.firstWhere((e) => e.value == state.substance);
                      } catch (_) {}
                    }

                    builderContext.read<AuthBloc>().add(
                      RegisterPatientEvent(
                        email: state.email!,
                        password: state.password!,
                        nom: state.nom ?? '',
                        prenom: state.prenom ?? '',
                        age: _calculateAge(state.dateNaissance!),
                        dateNaissance: state.dateNaissance!,
                        sobrietyDate: state.sobrietyDate,
                        addiction: addictionType,
                        imagePath: state.imagePath,
                        username: state.username,
                        prenamePrivate: state.prenamePrivate,
                        usageDuration: state.usageDuration,
                        hobbies: state.hobbies,
                        triggers: state.triggers,
                        copingMechanisms: state.copingMechanisms,
                        motivations: state.motivations,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
