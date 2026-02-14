import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../../core/models/addiction_type.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/theme/app_colors.dart';

class GoalPage extends StatelessWidget {
  final VoidCallback onNext;

  const GoalPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ton Objectif",
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Définis ta cible et ton point de départ.",
                  style: TextStyle(color: AppColors.getPremiumTextSecondary(context), fontSize: 14.sp),
                ),
                SizedBox(height: 32.h),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Substance Principale", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: AddictionType.values.map((type) {
                          final isSelected = state.substance == type.value;
                          return ChoiceChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            selectedColor: AppColors.primaryPurple,
                            backgroundColor: AppColors.getGlassColor(context).withOpacity(0.05),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.getPremiumTextSecondary(context),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            onSelected: (selected) {
                              context.read<OnboardingBloc>().add(SubstanceSelected(type.value));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date de Sobriété / Début", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 16.h),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: state.sobrietyDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppColors.primaryPurple,
                                    onPrimary: Colors.white,
                                    surface: AppColors.getGlassColor(context),
                                    onSurface: AppColors.getPremiumText(context),
                                  ),
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
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppColors.getGlassColor(context).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.getGlassBorder(context)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.sobrietyDate == null
                                    ? "Choisir une date"
                                    : DateFormat('dd MMM yyyy', 'fr_FR').format(state.sobrietyDate!),
                                style: TextStyle(
                                  fontSize: 16.sp, 
                                  color: state.sobrietyDate == null ? AppColors.getPremiumTextSecondary(context).withOpacity(0.5) : AppColors.getPremiumText(context),
                                ),
                              ),
                              Icon(Icons.calendar_today, size: 20.sp, color: AppColors.primaryPurple),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ton But Actuel", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 12.h),
                      ...['STOP_COMPLETELY', 'REDUCE_USAGE'].map((goal) {
                        return Theme(
                          data: Theme.of(context).copyWith(unselectedWidgetColor: AppColors.getPremiumTextSecondary(context).withOpacity(0.3)),
                          child: RadioListTile<String>(
                            title: Text(
                              goal == 'STOP_COMPLETELY' ? 'Arrêt Complet' : 'Réduction d\'usage',
                              style: TextStyle(color: AppColors.getPremiumText(context), fontSize: 14.sp),
                            ),
                            value: goal,
                            activeColor: AppColors.primaryPurple,
                            groupValue: state.goal,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              context.read<OnboardingBloc>().add(GoalSelected(val!));
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text("Suivant", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
}

