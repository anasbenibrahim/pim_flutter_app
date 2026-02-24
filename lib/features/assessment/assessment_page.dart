import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import '../../core/widgets/cosmic_background.dart';
import '../../core/services/api_service.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'steps/q1_health_goal.dart';
import 'steps/q2_gender.dart';
import 'steps/q3_mood.dart';
import 'steps/q4_sleep.dart';
import 'steps/q5_stress.dart';
import 'steps/q6_professional_help.dart';
import 'steps/q7_medications.dart';
import 'steps/q8_physical_distress.dart';
import 'steps/q9_personality.dart';
import 'steps/q10_mental_health.dart';

class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});
  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _submitting = false;
  static const int _totalPages = 10;

  // ─── Collected data ───
  String? healthGoal;
  String? gender;
  int? moodLevel;
  int? sleepQuality;
  int? stressLevel;
  bool? soughtHelp;
  bool? takingMeds;
  String? medications;
  bool? physicalDistress;
  List<String> symptoms = [];
  List<String> personalityTraits = [];
  List<String> mentalHealthConcerns = [];

  void _next() {
    if (_currentPage < _totalPages - 1) {
      Vibration.vibrate(duration: 10, amplitude: 60);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _back() {
    if (_currentPage > 0) {
      Vibration.vibrate(duration: 5, amplitude: 40);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    Vibration.vibrate(duration: 30, amplitude: 128);
    setState(() => _submitting = true);
    try {
      await ApiService().submitAssessment(
        gender: gender,
        healthGoal: healthGoal,
        moodLevel: moodLevel,
        sleepQuality: sleepQuality,
        stressLevel: stressLevel,
        soughtProfessionalHelp: soughtHelp,
        takingMedications: takingMeds,
        medications: medications,
        physicalDistress: physicalDistress,
        symptoms: symptoms,
        personalityTraits: personalityTraits,
        mentalHealthConcerns: mentalHealthConcerns,
      );
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthEvent());
        Navigator.of(context).pushReplacementNamed(AppRoutes.mainNavigation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.brick),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CosmicBackground(
        zoom: 1.0 + (_currentPage * 0.05),
        child: SafeArea(
          child: Column(
            children: [
            // ─── Top Bar ───
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _back,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
                      ),
                      child: Icon(
                        _currentPage > 0
                            ? Icons.arrow_back_rounded
                            : Icons.close_rounded,
                        size: 20.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Step counter pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${_currentPage + 1} of $_totalPages',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Progress bar (gradient pill) ───
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  height: 8.h,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (_currentPage + 1) / _totalPages),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    builder: (ctx, value, _) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.sapphire, Color(0xFF0A8F6F)],
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Pages ───
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  Q1HealthGoal(value: healthGoal, onChanged: (v) => setState(() => healthGoal = v), onNext: _next),
                  Q2Gender(value: gender, onChanged: (v) => setState(() => gender = v), onNext: _next),
                  Q3Mood(value: moodLevel, onChanged: (v) => setState(() => moodLevel = v), onNext: _next),
                  Q4Sleep(value: sleepQuality, onChanged: (v) => setState(() => sleepQuality = v), onNext: _next),
                  Q5Stress(value: stressLevel, onChanged: (v) => setState(() => stressLevel = v), onNext: _next),
                  Q6ProfessionalHelp(value: soughtHelp, onChanged: (v) => setState(() => soughtHelp = v), onNext: _next),
                  Q7Medications(
                    takingMeds: takingMeds, medications: medications,
                    onMedsChanged: (v) => setState(() => takingMeds = v),
                    onMedicationsChanged: (v) => setState(() => medications = v),
                    onNext: _next,
                  ),
                  Q8PhysicalDistress(
                    value: physicalDistress, symptoms: symptoms,
                    onChanged: (v) => setState(() => physicalDistress = v),
                    onSymptomsChanged: (v) => setState(() => symptoms = v),
                    onNext: _next,
                  ),
                  Q9Personality(selected: personalityTraits, onChanged: (v) => setState(() => personalityTraits = v), onNext: _next),
                  Q10MentalHealth(
                    selected: mentalHealthConcerns,
                    onChanged: (v) => setState(() => mentalHealthConcerns = v),
                    onSubmit: _submit,
                    submitting: _submitting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
