import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  
  const CustomDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButtonFormField<T>(
                initialValue: value,
                dropdownColor: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF1E1E1E) 
                    : Colors.white,
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
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.getPremiumTextSecondary(context).withOpacity(0.7),
                  size: 24.sp,
                ),
                items: items,
                onChanged: enabled ? onChanged : null,
                validator: validator,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
