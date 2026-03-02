import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vibration/vibration.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.buttonPurple,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading 
            ? null 
            : () async {
                if (await Vibration.hasVibrator()) {
                  Vibration.vibrate(duration: 15, amplitude: 128);
                }
                onPressed?.call();
              },
          borderRadius: BorderRadius.circular(25.r),
          child: Center(
            child: isLoading
                ? LoadingAnimationWidget.threeRotatingDots(
                    color: Colors.white,
                    size: 24.sp,
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
