import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/theme/app_colors.dart';

class CornerPage extends StatelessWidget {
  final VoidCallback onNext;

  const CornerPage({super.key, required this.onNext});

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
                  "Ton Coin",
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Dis-nous en plus sur ton environnement.",
                  style: TextStyle(color: AppColors.getPremiumTextSecondary(context), fontSize: 14.sp),
                ),
                SizedBox(height: 32.h),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Win toskon ? (Région)", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: ['TUNIS', 'ARIANA', 'SOUSSE', 'SFAX', 'AUTRE'].map((region) {
                          final isSelected = state.region == region;
                          return ChoiceChip(
                            label: Text(region),
                            selected: isSelected,
                            selectedColor: AppColors.primaryPurple,
                            backgroundColor: AppColors.getGlassColor(context).withOpacity(0.05),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.getPremiumTextSecondary(context),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            onSelected: (selected) {
                              context.read<OnboardingBloc>().add(RegionSelected(region));
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
                      Text("Chneya ta3mel fi 7yetek ?", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 12.h),
                      ...['STUDENT', 'PROFESSIONAL', 'UNEMPLOYED'].map((status) {
                        final isSelected = state.activityStatus == status;
                        return Theme(
                          data: Theme.of(context).copyWith(unselectedWidgetColor: AppColors.getPremiumTextSecondary(context).withOpacity(0.3)),
                          child: RadioListTile<String>(
                            title: Text(status, style: TextStyle(color: AppColors.getPremiumText(context), fontSize: 14.sp)),
                            value: status,
                            activeColor: AppColors.primaryPurple,
                            groupValue: state.activityStatus,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              context.read<OnboardingBloc>().add(ActivityStatusSelected(val!));
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rythme mte3ek ?", 
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context), fontSize: 16.sp)),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(child: _buildRhythmCard(context, 'MORNING_PERSON', Icons.wb_sunny, state.lifeRhythm)),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildRhythmCard(context, 'NIGHT_OWL', Icons.nights_stay, state.lifeRhythm)),
                        ],
                      ),
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

  Widget _buildRhythmCard(BuildContext context, String value, IconData icon, String? groupValue) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => context.read<OnboardingBloc>().add(LifeRhythmSelected(value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryPurple.withOpacity(0.2) : AppColors.getGlassColor(context).withOpacity(0.05),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.getGlassBorder(context),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: isSelected ? AppColors.primaryPurple : AppColors.getPremiumTextSecondary(context).withOpacity(0.5)),
            SizedBox(height: 12.h),
            Text(
              value == 'MORNING_PERSON' ? 'Matin' : 'Soir', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isSelected ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primaryPurple) : AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

