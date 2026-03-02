import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool showArrow;
  final Color? iconColor;

  final Widget? trailing;

  const MenuListTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.showArrow = true,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getGlassColor(context),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.getGlassBorder(context),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              leading: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryPurple).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryPurple,
                  size: 22.sp,
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.getPremiumText(context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
              trailing: trailing ?? (showArrow
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                      size: 16.sp,
                    )
                  : null),
              onTap: onTap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
