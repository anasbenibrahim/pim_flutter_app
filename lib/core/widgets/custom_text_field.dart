import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  
  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.getPremiumTextSecondary(context).withOpacity(0.9),
            fontWeight: FontWeight.normal,
            fontFamily: 'sans-serif',
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: AppColors.getGlassColor(context).withOpacity(0.05),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: AppColors.getGlassBorder(context),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                      controller: controller,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      validator: validator,
                      enabled: enabled,
                      readOnly: readOnly,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.getPremiumText(context),
                        fontWeight: FontWeight.normal,
                        fontFamily: 'sans-serif',
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                          fontWeight: FontWeight.normal,
                          fontFamily: 'sans-serif',
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                if (suffixIcon != null) suffixIcon!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
