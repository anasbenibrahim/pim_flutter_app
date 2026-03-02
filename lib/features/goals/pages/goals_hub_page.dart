import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../../../core/models/goal_model.dart';
import '../../navigation/pages/main_navigation_page.dart';
import '../../../core/models/goal_status.dart';


class GoalsHubPage extends StatelessWidget {
  const GoalsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalsBloc(apiService: ApiService())..add(LoadGoalsEvent()),
      child: const _GoalsHubPageView(),
    );
  }
}

class _GoalsHubPageView extends StatelessWidget {
  const _GoalsHubPageView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return BlocBuilder<GoalsBloc, GoalsState>(
              builder: (context, goalsState) {
                return SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<GoalsBloc>().add(const LoadGoalsEvent());
                    },
                    color: theme.colorScheme.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          SizedBox(height: 24.h),
                          _buildXPCard(context, authState, goalsState),
                          SizedBox(height: 20.h),
                          _buildActiveGoals(context, goalsState),
                          SizedBox(height: 20.h),
                          _buildCreateGoalButton(context),
                          SizedBox(height: 20.h),
                          _buildCompletedGoals(context, goalsState),
                          SizedBox(height: 20.h),
                          _buildFailedGoals(context, goalsState),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Set goals, track progress, earn rewards',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildXPCard(
    BuildContext context,
    AuthAuthenticated authState,
    GoalsState goalsState,
  ) {
    final theme = Theme.of(context);
    int totalXp = authState.user.totalXp;
    int level = authState.user.level;
    String levelTitle = authState.user.levelTitle ?? 'Beginner';
    int xpToNext = 50;
    double progress = 0;

    if (goalsState is GoalsLoaded && goalsState.gamification != null) {
      totalXp = goalsState.gamification!.totalXp;
      level = goalsState.gamification!.level;
      levelTitle = goalsState.gamification!.levelTitle;
      xpToNext = goalsState.gamification!.xpToNextLevel;
      progress = goalsState.gamification!.progressToNextLevel;
    } else if (goalsState is GoalCreated && goalsState.gamification != null) {
      totalXp = goalsState.gamification!.totalXp;
      level = goalsState.gamification!.level;
      levelTitle = goalsState.gamification!.levelTitle;
      xpToNext = goalsState.gamification!.xpToNextLevel;
      progress = goalsState.gamification!.progressToNextLevel;
    }

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
              Icon(
                Icons.emoji_events_rounded,
                color: AppColors.sunflower,
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $level',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    levelTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalXp XP',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    xpToNext > 0 ? '$xpToNext XP to next' : 'Max level',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sunflower),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGoals(BuildContext context, GoalsState goalsState) {
    final theme = Theme.of(context);

    if (goalsState is GoalsLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppColors.getGlassColor(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.getGlassBorder(context)),
        ),
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2),
        ),
      );
    }

    List<GoalModel> activeGoals = [];
    if (goalsState is GoalsLoaded) {
      activeGoals = goalsState.goals.where((g) => g.status == GoalStatus.inProgress).toList();
    } else if (goalsState is GoalCreated) {
      activeGoals = goalsState.goals.where((g) => g.status == GoalStatus.inProgress).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Goals',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        if (activeGoals.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.getGlassColor(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.getGlassBorder(context)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 48.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No active goals',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Create your first goal to start earning XP and badges',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...activeGoals.map((g) => _GoalCard(goal: g)),
      ],
    );
  }

  Widget _buildCompletedGoals(BuildContext context, GoalsState goalsState) {
    final theme = Theme.of(context);

    List<GoalModel> completedGoals = [];
    if (goalsState is GoalsLoaded) {
      completedGoals = goalsState.goals.where((g) => g.status == GoalStatus.validated).toList();
    } else if (goalsState is GoalCreated) {
      completedGoals = goalsState.goals.where((g) => g.status == GoalStatus.validated).toList();
    }
    if (completedGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validated',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        ...completedGoals.map((g) => _CompletedGoalCard(goal: g)),
      ],
    );
  }

  Widget _buildFailedGoals(BuildContext context, GoalsState goalsState) {
    final theme = Theme.of(context);

    List<GoalModel> failedGoals = [];
    if (goalsState is GoalsLoaded) {
      failedGoals = goalsState.goals.where((g) => g.status == GoalStatus.failed).toList();
    } else if (goalsState is GoalCreated) {
      failedGoals = goalsState.goals.where((g) => g.status == GoalStatus.failed).toList();
    }
    if (failedGoals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Failed',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        ...failedGoals.map((g) => _FailedGoalCard(goal: g)),
      ],
    );
  }

  Widget _buildCreateGoalButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: () async {
          final bloc = context.read<GoalsBloc>();
          await Navigator.of(context).pushNamed(
            AppRoutes.createGoal,
            arguments: bloc,
          );
          if (context.mounted) {
            context.read<GoalsBloc>().add(const LoadGoalsEvent());
          }
        },
        icon: Icon(Icons.add_rounded, size: 22.sp),
        label: Text(
          'Create a goal',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _CompletedGoalCard extends StatelessWidget {
  final GoalModel goal;

  const _CompletedGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Validated',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FailedGoalCard extends StatelessWidget {
  final GoalModel goal;

  const _FailedGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.brick.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.cancel_rounded, color: AppColors.brick, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Failed',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.brick,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalModel goal;

  _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () async {
        final bloc = context.read<GoalsBloc>();
        final result = await Navigator.of(context).pushNamed(
          AppRoutes.goalTrackingBase,
          arguments: {'goalId': goal.id, 'hubBloc': bloc},
        );
        final validated = result == true;
        if (context.mounted) {
          bloc.add(const LoadGoalsEvent());
          if (validated == true) {
            GoalsTabScope.maybeOf(context)?.switchToGoalsTab();
          }
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.getGlassColor(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.getGlassBorder(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.flag_rounded, color: theme.colorScheme.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 6.h,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 24.sp),
          ],
        ),
      ),
    );
  }
}
