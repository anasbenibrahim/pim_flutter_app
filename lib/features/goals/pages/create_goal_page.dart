import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/models/goal_category.dart';
import '../../../core/models/goal_difficulty.dart';
import '../bloc/goals_bloc.dart';
import '../bloc/goals_event.dart';
import '../bloc/goals_state.dart';
import '../models/predefined_goal.dart';

class CreateGoalPage extends StatelessWidget {
  const CreateGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CreateGoalPageView();
  }
}

class _CreateGoalPageView extends StatefulWidget {
  const _CreateGoalPageView();

  @override
  State<_CreateGoalPageView> createState() => _CreateGoalPageViewState();
}

class _CreateGoalPageViewState extends State<_CreateGoalPageView> {
  GoalCategory _category = GoalCategory.timeBased;
  PredefinedGoal? _selectedGoal;
  bool _isCustom = false;
  final _customTitleController = TextEditingController();
  final _customTargetController = TextEditingController(text: '7');
  String _customUnit = 'days';
  GoalDifficulty _customDifficulty = GoalDifficulty.medium;

  @override
  void dispose() {
    _customTitleController.dispose();
    _customTargetController.dispose();
    super.dispose();
  }

  List<PredefinedGoal> get _goals {
    switch (_category) {
      case GoalCategory.timeBased:
        return timeBasedGoals;
      case GoalCategory.reductionBased:
        return reductionGoals;
      case GoalCategory.alternativeBehavior:
        return alternativeGoals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: CustomAppBar(
        title: 'Create a goal',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BlocConsumer<GoalsBloc, GoalsState>(
        listenWhen: (p, c) => c is GoalsError || c is GoalCreated,
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
          if (state is GoalCreated) {
            Get.snackbar(
              'Success',
              'Goal created',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is GoalsLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCategoryTabs(context),
                SizedBox(height: 24.h),
                _buildGoalList(context),
                if (_isCustom) ...[
                  SizedBox(height: 20.h),
                  _buildCustomForm(context),
                ],
                SizedBox(height: 32.h),
                _buildCreateButton(context, isLoading),
                SizedBox(height: 16.h),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
      ),
      child: Row(
        children: GoalCategory.values.map((c) {
          final isActive = _category == c;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _category = c;
                  _selectedGoal = null;
                  _isCustom = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isActive ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  c.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalList(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your goal',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        ..._goals.map((g) => _buildGoalTile(context, g)),
        _buildCustomTile(context),
      ],
    );
  }

  Widget _buildGoalTile(BuildContext context, PredefinedGoal goal) {
    final theme = Theme.of(context);
    final isSelected = _selectedGoal == goal && !_isCustom;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedGoal = goal;
        _isCustom = false;
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : AppColors.getGlassColor(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : AppColors.getGlassBorder(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: _difficultyColor(goal.difficulty).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          goal.difficulty.displayName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _difficultyColor(goal.difficulty),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        '+${goal.difficulty.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sunflower,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTile(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = _isCustom;

    return GestureDetector(
      onTap: () => setState(() {
        _isCustom = true;
        _selectedGoal = null;
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.08)
              : AppColors.getGlassColor(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : AppColors.getGlassBorder(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Text(
              'Custom goal...',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, {String? hint, IconData? prefixIcon}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 15.sp,
        color: theme.colorScheme.onSurface.withOpacity(0.35),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: theme.colorScheme.primary, size: 20.sp)
          : null,
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.getGlassBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.getGlassBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildCustomForm(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Title',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _customTitleController,
            style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface),
            decoration: _inputDecoration(context, hint: 'e.g. 14 days clean', prefixIcon: Icons.flag_rounded),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _customTargetController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface),
                      decoration: _inputDecoration(context, hint: '7', prefixIcon: Icons.numbers),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.getGlassBorder(context)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _customUnit,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        dropdownColor: theme.colorScheme.surface,
                        style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface),
                        items: ['days', 'hours', 'sessions', 'cigarettes']
                            .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) => setState(() => _customUnit = v ?? 'days'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.85),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: GoalDifficulty.values.map((d) {
              final isSelected = _customDifficulty == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _customDifficulty = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: d != GoalDifficulty.values.last ? 10.w : 0),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : AppColors.getGlassColor(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : AppColors.getGlassBorder(context),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          d.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '+${d.xpReward} XP',
                          style: TextStyle(fontSize: 10.sp, color: AppColors.sunflower, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(GoalDifficulty d) {
    switch (d) {
      case GoalDifficulty.easy:
        return AppColors.success;
      case GoalDifficulty.medium:
        return AppColors.sunflower;
      case GoalDifficulty.hard:
        return AppColors.brick;
    }
  }

  Widget _buildCreateButton(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);

    String title = '';
    GoalDifficulty difficulty = GoalDifficulty.easy;
    int targetValue = 1;
    String? targetUnit;
    int? initialValue;

    if (_isCustom) {
      title = _customTitleController.text.trim();
      if (title.isEmpty) title = 'Custom goal';
      difficulty = _customDifficulty;
      targetValue = int.tryParse(_customTargetController.text) ?? 7;
      targetUnit = _customUnit;
      initialValue = null;
    } else if (_selectedGoal != null) {
      title = _selectedGoal!.title;
      difficulty = _selectedGoal!.difficulty;
      targetValue = _selectedGoal!.targetValue;
      targetUnit = _selectedGoal!.targetUnit;
      initialValue = _selectedGoal!.initialValue;
    }

    final canCreate = _isCustom ? (_customTitleController.text.trim().isNotEmpty) : (_selectedGoal != null);

    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: canCreate && !isLoading
            ? () {
                context.read<GoalsBloc>().add(CreateGoalEvent(
                      category: _category,
                      title: title,
                      difficulty: difficulty,
                      targetValue: targetValue,
                      targetUnit: targetUnit,
                      initialValue: initialValue,
                    ));
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: isLoading
            ? SizedBox(width: 24.w, height: 24.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Create goal', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
