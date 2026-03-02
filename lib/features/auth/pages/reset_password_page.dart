import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordPage({super.key, required this.email, required this.otpCode});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        Get.snackbar('Erreur', 'Les mots de passe ne correspondent pas',
          snackPosition: SnackPosition.TOP, backgroundColor: _brick,
          colorText: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
        return;
      }
      context.read<AuthBloc>().add(
        ResetPasswordEvent(
          email: widget.email, otpCode: widget.otpCode,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

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
          } else if (state is PasswordResetSuccessState) {
            Get.snackbar('Succès', 'Mot de passe réinitialisé avec succès !',
              snackPosition: SnackPosition.TOP, backgroundColor: _emerald,
              colorText: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 32.h),

                  // Icon
                  Container(
                    width: 80.w, height: 80.w,
                    decoration: BoxDecoration(color: _sapphire.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.lock_open_rounded, color: _sapphire, size: 40.sp),
                  ),
                  SizedBox(height: 28.h),

                  Text('Nouveau mot de passe', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5), textAlign: TextAlign.center),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text('Créez un mot de passe fort pour sécuriser votre compte.',
                      style: TextStyle(fontSize: 14.sp, color: _indigo.withOpacity(0.5), height: 1.5), textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 36.h),

                  // New Password
                  _passwordField('Nouveau mot de passe', _newPasswordController, _obscureNewPassword,
                    () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                    (v) { if (v == null || v.isEmpty) return 'Requis'; if (v.length < 6) return 'Mini 6 caractères'; return null; }),
                  SizedBox(height: 16.h),

                  // Confirm Password
                  _passwordField('Confirmer le mot de passe', _confirmPasswordController, _obscureConfirmPassword,
                    () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    (v) { if (v == null || v.isEmpty) return 'Requis'; if (v != _newPasswordController.text) return 'Ne correspond pas'; return null; }),
                  SizedBox(height: 32.h),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sapphire, foregroundColor: Colors.white,
                        disabledBackgroundColor: _sapphire.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                      ),
                      child: state is AuthLoading
                          ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('Réinitialiser', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                              SizedBox(width: 8.w), Icon(Icons.check_circle_outline_rounded, size: 18.sp),
                            ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController ctrl, bool obscure, VoidCallback toggle, String? Function(String?) validator) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _indigo.withOpacity(0.7))),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl, obscureText: obscure,
        style: TextStyle(fontSize: 15.sp, color: _indigo),
        decoration: InputDecoration(
          hintText: '••••••••', hintStyle: TextStyle(color: _indigo.withOpacity(0.25), fontSize: 15.sp),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: _sapphire, size: 20.sp),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: _indigo.withOpacity(0.3), size: 20.sp), onPressed: toggle),
          filled: true, fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _indigo.withOpacity(0.08))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _indigo.withOpacity(0.08))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _sapphire, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _brick)),
        ),
        validator: validator,
      ),
    ]);
  }
}
