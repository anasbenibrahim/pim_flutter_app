import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);

class CornerPage extends StatelessWidget {
  final VoidCallback onNext;

  const CornerPage({super.key, required this.onNext});

  static const _regionOptions = ['TUNIS', 'ARIANA', 'BEN_AROUS', 'MANOUBA', 'SOUSSE', 'SFAX', 'NABEUL', 'BIZERTE', 'MONASTIR', 'KAIROUAN', 'AUTRE'];
  static const _activityLabels = {
    'STUDENT': '📚  Étudiant',
    'PROFESSIONAL': '💼  Professionnel',
    'UNEMPLOYED': '🔍  Sans emploi',
    'RETIRED': '🌅  Retraité',
  };
  static const _rhythmOptions = {
    'MORNING_PERSON': '🌅  Lève-tôt',
    'NIGHT_OWL': '🌙  Couche-tard',
    'IRREGULAR': '🔄  Irrégulier',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _linen,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ton Coin", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
                SizedBox(height: 6.h),
                Text("Dis-nous en plus sur ton environnement.", style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp)),
                SizedBox(height: 28.h),

                // ─── Region ───
                _sectionLabel('Win toskon ? (Région)'),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w, runSpacing: 8.h,
                  children: _regionOptions.map((region) {
                    final selected = state.region == region;
                    return GestureDetector(
                      onTap: () => context.read<OnboardingBloc>().add(RegionSelected(region)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selected ? _sapphire : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: selected ? _sapphire : _indigo.withOpacity(0.08)),
                        ),
                        child: Text(
                          region.replaceAll('_', ' '),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: selected ? Colors.white : _indigo.withOpacity(0.7)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 28.h),

                // ─── Activity Status ───
                _sectionLabel('Chneya ta3mel fi 7yetek ?'),
                SizedBox(height: 10.h),
                Column(
                  children: _activityLabels.entries.map((e) {
                    final selected = state.activityStatus == e.key;
                    return GestureDetector(
                      onTap: () => context.read<OnboardingBloc>().add(ActivityStatusSelected(e.key)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selected ? _emerald.withOpacity(0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: selected ? _emerald : _indigo.withOpacity(0.08)),
                        ),
                        child: Text(e.value, style: TextStyle(
                          fontSize: 14.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _indigo : _indigo.withOpacity(0.6),
                        )),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),

                // ─── Life Rhythm ───
                _sectionLabel('Rythme mte3ek ?'),
                SizedBox(height: 10.h),
                Row(
                  children: _rhythmOptions.entries.map((e) {
                    final selected = state.lifeRhythm == e.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => context.read<OnboardingBloc>().add(LifeRhythmSelected(e.key)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: e.key != 'IRREGULAR' ? 8.w : 0),
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          decoration: BoxDecoration(
                            color: selected ? _sunflower.withOpacity(0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: selected ? _sunflower : _indigo.withOpacity(0.08)),
                          ),
                          child: Center(child: Text(e.value, style: TextStyle(
                            fontSize: 12.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? _indigo : _indigo.withOpacity(0.55),
                          ), textAlign: TextAlign.center)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 36.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sapphire, foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Suivant", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
                    ]),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) =>
    Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _indigo));
}
