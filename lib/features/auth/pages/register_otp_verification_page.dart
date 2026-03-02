import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);

class RegisterOtpVerificationPage extends StatefulWidget {
  final String email;
  final String userRole;
  final String? imagePath;

  const RegisterOtpVerificationPage({
    super.key, required this.email, required this.userRole, this.imagePath,
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
          email: widget.email, otpCode: _otpController.text.trim(),
          userRole: widget.userRole, imagePath: widget.imagePath,
        ),
      );
    } else {
      Get.snackbar('Erreur', 'Veuillez entrer le code OTP complet à 6 chiffres',
        snackPosition: SnackPosition.TOP, backgroundColor: _brick,
        colorText: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
    }
  }

  PinTheme _defaultPin() => PinTheme(
    width: 48.w, height: 56.h,
    textStyle: TextStyle(fontSize: 22.sp, color: _indigo, fontWeight: FontWeight.w700),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _indigo.withOpacity(0.1)),
      borderRadius: BorderRadius.circular(14.r),
    ),
  );

  PinTheme _focusedPin() => _defaultPin().copyWith(
    decoration: _defaultPin().decoration!.copyWith(
      border: Border.all(color: _sapphire, width: 2),
    ),
  );

  PinTheme _submittedPin() => _defaultPin().copyWith(
    decoration: _defaultPin().decoration!.copyWith(
      color: _sapphire.withOpacity(0.05),
      border: Border.all(color: _sapphire),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _linen,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: _indigo, size: 20.sp), onPressed: () => Navigator.pop(context)),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar('Erreur', state.message, snackPosition: SnackPosition.TOP,
              backgroundColor: _brick, colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
          } else if (state is AuthOnboardingRequired) {
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),

                // Icon
                Container(
                  width: 80.w, height: 80.w,
                  decoration: BoxDecoration(color: _emerald.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(Icons.mark_email_read_outlined, color: _emerald, size: 40.sp),
                ),
                SizedBox(height: 28.h),

                Text('Vérifiez votre email', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5), textAlign: TextAlign.center),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text('Entrez le code à 6 chiffres envoyé à\n${widget.email}',
                    style: TextStyle(fontSize: 14.sp, color: _indigo.withOpacity(0.5), height: 1.5), textAlign: TextAlign.center),
                ),
                SizedBox(height: 40.h),

                // PIN
                Pinput(
                  length: 6, controller: _otpController,
                  defaultPinTheme: _defaultPin(), focusedPinTheme: _focusedPin(), submittedPinTheme: _submittedPin(),
                  pinAnimationType: PinAnimationType.fade, keyboardType: TextInputType.number, autofocus: true,
                  onCompleted: (pin) => _handleVerifyOtp(),
                  cursor: Container(width: 2.w, height: 22.h, decoration: BoxDecoration(color: _sapphire, borderRadius: BorderRadius.circular(1.r))),
                ),
                SizedBox(height: 36.h),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sapphire, foregroundColor: Colors.white,
                      disabledBackgroundColor: _sapphire.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                    ),
                    child: state is AuthLoading
                        ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('Vérifier', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
                          ]),
                  ),
                ),
                SizedBox(height: 20.h),

                // Resend
                TextButton(
                  onPressed: () {
                    Get.snackbar('Info', 'Veuillez soumettre à nouveau votre inscription pour recevoir un nouveau code.',
                      snackPosition: SnackPosition.TOP, backgroundColor: _sapphire,
                      colorText: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
                  },
                  child: Text('Renvoyer le code', style: TextStyle(fontSize: 14.sp, color: _sapphire, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
