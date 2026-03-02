import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../../core/models/goal_model.dart';
import '../../../core/models/goal_status.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../widgets/validate_goal_modal.dart';

class GoalTrackingPage extends StatelessWidget {
  final int goalId;
  final GoalsBloc? hubBloc;

  const GoalTrackingPage({super.key, required this.goalId, this.hubBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalsBloc(apiService: ApiService())..add(LoadGoalEvent(goalId)),
      child: _GoalTrackingPageView(goalId: goalId, hubBloc: hubBloc),
    );
  }
}

class _GoalTrackingPageView extends StatelessWidget {
  final int goalId;
  final GoalsBloc? hubBloc;

  const _GoalTrackingPageView({required this.goalId, this.hubBloc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: CustomAppBar(
        title: 'Goal progress',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<GoalsBloc, GoalsState>(
        listenWhen: (p, c) => c is GoalsError || c is GoalValidated,
        listener: (context, state) {
          if (state is GoalsError) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
            );
          }
          if (state is GoalValidated) {
            context.read<AuthBloc>().add(const CheckAuthEvent());
            hubBloc?.add(const LoadGoalsEvent());
            Get.snackbar(
              'Well done!',
              state.gamification.motivationalMessage ?? 'You did it!',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
              duration: const Duration(seconds: 4),
            );
            Navigator.pop(context, true); // true = validated, return to Goals tab
          }
        },
        builder: (context, state) {
          if (state is GoalsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2),
                  SizedBox(height: 16.h),
                  Text('Loading...', style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            );
          }
          if (state is GoalDetailLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGoalCard(context, state.goal),
                  SizedBox(height: 24.h),
                  _buildProgressSection(context, state.goal),
                  SizedBox(height: 24.h),
                  _buildCheckInsSection(context, state.goal),
                  if (state.goal.status == GoalStatus.inProgress) ...[
                    SizedBox(height: 24.h),
                    _buildValidateButton(context, state.goal),
                  ],
                ],
              ),
            );
          }
          if (state is GoalsError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                    SizedBox(height: 16.h),
                    Text(state.message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface)),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () => context.read<GoalsBloc>().add(LoadGoalEvent(goalId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: AppColors.sunflower, size: 28.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              goal.status.displayName,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${goal.currentValue}/${goal.targetValue} ${goal.targetUnit ?? 'days'}',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            Text(
              '+${goal.xpReward} XP',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.sunflower),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: goal.progress,
            minHeight: 10.h,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInsSection(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily check-ins',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: List.generate(goal.targetValue, (i) {
            final dayIndex = i + 1;
            final checkInDate = goal.startDate.add(Duration(days: i));
            final hasCheckedIn = goal.checkInDates.any((d) =>
                d.year == checkInDate.year && d.month == checkInDate.month && d.day == checkInDate.day);
            final isToday = DateTime.now().year == checkInDate.year &&
                DateTime.now().month == checkInDate.month &&
                DateTime.now().day == checkInDate.day;
            final isPast = checkInDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

            return GestureDetector(
              onTap: goal.status == GoalStatus.inProgress && (isToday || isPast) && !hasCheckedIn
                  ? () => context.read<GoalsBloc>().add(AddCheckInEvent(goalId, checkInDate))
                  : null,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: hasCheckedIn
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.getGlassColor(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: hasCheckedIn ? AppColors.success : AppColors.getGlassBorder(context),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasCheckedIn ? Icons.check_circle : Icons.circle_outlined,
                      size: 20.sp,
                      color: hasCheckedIn ? AppColors.success : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Day $dayIndex',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildValidateButton(BuildContext context, GoalModel goal) {
    final theme = Theme.of(context);
    final canValidate = goal.canValidate;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: canValidate
            ? () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => ValidateGoalModal(
                    goal: goal,
                    onConfirm: (note) {
                      Navigator.pop(ctx);
                      context.read<GoalsBloc>().add(ValidateGoalEvent(goalId, note));
                    },
                  ),
                )
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(
          canValidate ? 'Validate goal' : 'Keep going! (${goal.targetValue - goal.currentValue} left)',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
