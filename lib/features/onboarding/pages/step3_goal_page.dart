import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../core/models/addiction_type.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);

class GoalPage extends StatelessWidget {
  final VoidCallback onNext;

  const GoalPage({super.key, required this.onNext});

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
                Text("Ton Objectif", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
                SizedBox(height: 6.h),
                Text("Définis ta cible et ton point de départ.", style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp)),
                SizedBox(height: 28.h),

                // ─── Substance ───
                _sectionLabel('Substance Principale'),
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
                          color: selected ? _sapphire : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: selected ? _sapphire : _indigo.withOpacity(0.08)),
                        ),
                        child: Text(type.displayName, style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : _indigo.withOpacity(0.7),
                        )),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 28.h),

                // ─── Sobriety Date ───
                _sectionLabel('Date de Sobriété / Début'),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.sobrietyDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) {
                        return Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: ColorScheme.light(primary: _sapphire, onPrimary: Colors.white, surface: _linen, onSurface: _indigo),
                            dialogBackgroundColor: _linen,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      context.read<OnboardingBloc>().add(SobrietyDateSelected(picked));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: _indigo.withOpacity(0.08)),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_month_rounded, color: _emerald, size: 20.sp),
                      SizedBox(width: 12.w),
                      Text(
                        state.sobrietyDate == null
                            ? 'Choisir une date'
                            : DateFormat('dd MMM yyyy', 'fr_FR').format(state.sobrietyDate!),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: state.sobrietyDate != null ? _indigo : _indigo.withOpacity(0.25),
                        ),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: 28.h),

                // ─── Goal ───
                _sectionLabel('Ton But Actuel'),
                SizedBox(height: 10.h),
                ...['STOP_COMPLETELY', 'REDUCE_USAGE'].map((goal) {
                  final selected = state.goal == goal;
                  final label = goal == 'STOP_COMPLETELY' ? '🛑  Arrêt Complet' : '📉  Réduction d\'usage';
                  return GestureDetector(
                    onTap: () => context.read<OnboardingBloc>().add(GoalSelected(goal)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: selected ? _emerald.withOpacity(0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: selected ? _emerald : _indigo.withOpacity(0.08)),
                      ),
                      child: Text(label, style: TextStyle(
                        fontSize: 15.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? _indigo : _indigo.withOpacity(0.6),
                      )),
                    ),
                  );
                }),
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
