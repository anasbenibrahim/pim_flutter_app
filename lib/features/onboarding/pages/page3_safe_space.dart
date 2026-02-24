import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../core/models/addiction_type.dart';

const _sapphire  = Color(0xFF0D6078);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);

const _durationOptions = {
  'LESS_THAN_1_YEAR': '< 1 an',
  '1_TO_3_YEARS': '1–3 ans',
  '3_TO_5_YEARS': '3–5 ans',
  '5_TO_10_YEARS': '5–10 ans',
  'MORE_THAN_10_YEARS': '10+ ans',
};

const _triggerOptions = [
  'Stress', 'Ennui', 'Pression sociale', 'Problèmes familiaux',
  'Douleur physique', 'Insomnie', 'Solitude', 'Fêtes / Sorties',
  'Travail', 'Conflits relationnels', 'Anxiété', 'Autre',
];

class Page3SafeSpace extends StatelessWidget {
  final VoidCallback onFinish;
  const Page3SafeSpace({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent, // Background provided by PageView wrapper
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12.h),

                // ─── Progress Dots ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    width: i == 2 ? 24.w : 8.w,
                    height: 8.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: i <= 2 ? _emerald : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  )),
                ),
                SizedBox(height: 16.h),

                // ─── Supportive Hopi ───
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 10),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOutSine,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value - 5),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/hopi/hapi_idle_tpbg.webp',
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 12.h),

                // ─── Header ───
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    children: [
                      Text(
                        'Espace Confidentiel 🤫',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Rien de ce que tu partages ici ne sera visible.\nHopi est là pour toi, sans jugement.',
                        style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.8), height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ─── Scrollable Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Substance ───
                        _sectionLabel('Quelle substance traverses-tu ?'),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w, runSpacing: 8.h,
                          children: AddictionType.values.map((type) {
                            final selected = state.substance == type.value;
                            return GestureDetector(
                              onTap: () => context.read<OnboardingBloc>().add(SubstanceSelected(type.value)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: selected ? _emerald : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  type.displayName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                                    color: selected ? _sapphire : Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Duration ───
                        _sectionLabel('Durée d\'utilisation'),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w, runSpacing: 8.h,
                          children: _durationOptions.entries.map((e) {
                            final selected = state.usageDuration == e.key;
                            return GestureDetector(
                              onTap: () => context.read<OnboardingBloc>().add(UsageDurationSelected(e.key)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: selected ? _emerald : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                                    color: selected ? _sapphire : Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Triggers ───
                        _sectionLabel('Qu\'est-ce qui déclenche l\'envie ?'),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w, runSpacing: 8.h,
                          children: _triggerOptions.map((trigger) {
                            final selected = state.triggers.contains(trigger);
                            return GestureDetector(
                              onTap: () => context.read<OnboardingBloc>().add(TriggerToggled(trigger)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: selected ? _emerald.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  trigger,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                    color: selected ? _sapphire : Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ),

                // ─── CTA ───
                Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 8.h, 28.w, 20.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onFinish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _emerald,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('S\'inscrire', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                          SizedBox(width: 8.w),
                          Icon(Icons.check_circle_rounded, size: 18.sp),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.9)),
  );
}
