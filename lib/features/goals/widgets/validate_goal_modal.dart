import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/goal_model.dart';

class ValidateGoalModal extends StatefulWidget {
  final GoalModel goal;
  final void Function(String? note) onConfirm;

  const ValidateGoalModal({
    super.key,
    required this.goal,
    required this.onConfirm,
  });

  @override
  State<ValidateGoalModal> createState() => _ValidateGoalModalState();
}

class _ValidateGoalModalState extends State<ValidateGoalModal> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            border: Border(
              top: BorderSide(color: AppColors.getGlassBorder(context)),
              left: BorderSide(color: AppColors.getGlassBorder(context)),
              right: BorderSide(color: AppColors.getGlassBorder(context)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.25),
                          AppColors.success.withOpacity(0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32.sp),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm your achievement',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            widget.goal.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.getGlassColor(context),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.getGlassBorder(context)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: theme.colorScheme.primary, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'I confirm that I have reached my goal.',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Add a note (optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: TextStyle(fontSize: 15.sp, color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'How do you feel? What helped you?',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                    fontWeight: FontWeight.w500,
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: EdgeInsets.all(16.w),
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
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: AppColors.getGlassBorder(context), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        foregroundColor: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => widget.onConfirm(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        shadowColor: theme.colorScheme.primary.withOpacity(0.35),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Confirm', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
