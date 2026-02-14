import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/widgets/premium_widgets.dart';
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
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthLoading) return;

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
        'Erreur',
        'Veuillez entrer le code OTP complet à 6 chiffres',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        borderRadius: 12.r,
      );
    }
  }
  
  PinTheme _getPinTheme() {
    return PinTheme(
      width: 50.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
  
  PinTheme _getFocusedPinTheme() {
    return _getPinTheme().copyWith(
      decoration: _getPinTheme().decoration!.copyWith(
        border: Border.all(
          color: AppColors.primaryPurple,
          width: 2,
        ),
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }
  
  PinTheme _getSubmittedPinTheme() {
    return _getPinTheme().copyWith(
      decoration: _getPinTheme().decoration!.copyWith(
        color: AppColors.primaryPurple.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primaryPurple,
          width: 1,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Vérification',
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar(
              'Erreur',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 12.r,
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
          } else if (state is AuthOnboardingRequired) {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryPurple,
                    size: 64.sp,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'Code de vérification',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Entrez le code à 6 chiffres envoyé à\n${widget.email}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 48.h),
                GlassCard(
                  child: Column(
                    children: [
                      Pinput(
                        length: 6,
                        controller: _otpController,
                        defaultPinTheme: _getPinTheme(),
                        focusedPinTheme: _getFocusedPinTheme(),
                        submittedPinTheme: _getSubmittedPinTheme(),
                        pinAnimationType: PinAnimationType.fade,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        onCompleted: (pin) => _handleVerifyOtp(),
                        cursor: Container(
                          width: 2.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading ? null : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            elevation: 0,
                          ),
                          child: state is AuthLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.h,
                                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('Vérifier', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      TextButton(
                        onPressed: () {
                          Get.snackbar(
                            'Info',
                            'Veuillez soumettre à nouveau votre inscription pour recevoir un nouveau code.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.primaryPurple,
                            colorText: Colors.white,
                            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            borderRadius: 12.r,
                          );
                        },
                        child: Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
