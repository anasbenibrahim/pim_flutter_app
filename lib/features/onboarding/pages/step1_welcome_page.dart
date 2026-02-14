import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // HopeUp Integrated Branding Section
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                   ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [AppColors.primaryPurple, Color(0xFF00F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      'HopeUp',
                      style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const HopeUpLogo(size: 160),
                  SizedBox(height: 16.h),
                  Text(
                    "Marhba bik",
                    style: TextStyle(
                      fontSize: 28.sp, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.getPremiumText(context),
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            GlassCard(
              child: Column(
                children: [
                  Text(
                    "Houni, naavanciw m3ak 5atwa 5atwa.\nIci, on avance avec toi pas à pas.",
                    style: TextStyle(fontSize: 15.sp, color: AppColors.getPremiumTextSecondary(context), height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        "Abda tawa (Commencer)",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    child: Text(
                      "Plus tard",
                      style: TextStyle(color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5), fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}

