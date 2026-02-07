import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.normal,
            fontFamily: 'sans-serif',
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DropdownButtonFormField<T>(
                initialValue: value,
                dropdownColor: const Color(0xFF1E1E1E),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'sans-serif',
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white.withValues(alpha: 0.5),
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
                  color: Colors.white.withValues(alpha: 0.7),
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
