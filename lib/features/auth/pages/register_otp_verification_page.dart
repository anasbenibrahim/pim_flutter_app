import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterOtpVerificationPage extends StatefulWidget {
  final String email;
  final String userRole;
  final String? imagePath;
  
  const RegisterOtpVerificationPage({
    super.key,
    required this.email,
    required this.userRole,
    this.imagePath,
  });
  
  @override
  State<RegisterOtpVerificationPage> createState() => _RegisterOtpVerificationPageState();
}

class _RegisterOtpVerificationPageState extends State<RegisterOtpVerificationPage> {
  final _otpController = TextEditingController();
  
  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
  
  void _handleVerifyOtp() {
    if (_otpController.text.length == 6) {
      context.read<AuthBloc>().add(
        VerifyRegistrationOtpEvent(
          email: widget.email,
          otpCode: _otpController.text.trim(),
          userRole: widget.userRole,
          imagePath: widget.imagePath,
        ),
      );
    } else {
      Get.snackbar(
        'Error',
        'Please enter the complete 6-digit OTP code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        borderRadius: 8.r,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  PinTheme _getPinTheme() {
    return PinTheme(
      width: 50.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
  
  PinTheme _getFocusedPinTheme() {
    return PinTheme(
      width: 50.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border.all(
          color: AppColors.primaryPurple,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
  
  PinTheme _getSubmittedPinTheme() {
    return PinTheme(
      width: 50.w,
      height: 56.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primaryPurple,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: const CustomAppBar(
        title: 'Verify OTP',
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
              duration: const Duration(seconds: 3),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    'Enter OTP Code',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'We\'ve sent a 6-digit code to ${widget.email}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // OTP Field Label
                  Text(
                    'OTP Code',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // PIN Input with 6 cases - Centered
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: _otpController,
                      defaultPinTheme: _getPinTheme(),
                      focusedPinTheme: _getFocusedPinTheme(),
                      submittedPinTheme: _getSubmittedPinTheme(),
                      pinAnimationType: PinAnimationType.fade,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onCompleted: (pin) {
                        _handleVerifyOtp();
                      },
                      cursor: Container(
                        width: 2.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Resend OTP Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // Resend OTP by re-initiating registration
                        // This would require storing the registration data, which we'll handle via state
                        Get.snackbar(
                          'Info',
                          'Please go back and resubmit registration to receive a new OTP',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.primaryPurple,
                          colorText: Colors.white,
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          borderRadius: 8.r,
                          duration: const Duration(seconds: 3),
                        );
                      },
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.primaryPurple,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Verify Button
                  CustomButton(
                    text: 'Verify OTP',
                    onPressed: state is AuthLoading ? null : _handleVerifyOtp,
                    isLoading: state is AuthLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
