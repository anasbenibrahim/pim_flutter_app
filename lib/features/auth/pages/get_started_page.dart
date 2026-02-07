import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/routes/app_routes.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.medical_services,
                size: 100.sp,
                color: const Color(0xFF6B45F1),
              ),
              SizedBox(height: 32.h),
              Text(
                'Welcome to PIM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                  color: Colors.white,
                  fontFamily: 'sans-serif',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your personal health management companion',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16.sp,
                  fontFamily: 'sans-serif',
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.w,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.roleSelection);
                    },
                    borderRadius: BorderRadius.circular(25.r),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
