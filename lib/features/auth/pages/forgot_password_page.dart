import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

const _forestGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFB5DDE6), // Light sapphire tint
    Color(0xFF5BA8B8), // Mid sapphire
    Color(0xFF0D6078), // Sapphire
    Color(0xFF053545), // Transition
    Color(0xFF022F40), // Indigo
  ],
  stops: [0.0, 0.2, 0.45, 0.75, 1.0],
);

const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ForgotPasswordEvent(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _forestGradient),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent, elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    Get.snackbar('Erreur', state.message, snackPosition: SnackPosition.TOP,
                      backgroundColor: _brick, colorText: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), borderRadius: 12.r);
                  } else if (state is OtpSentState) {
                    Navigator.pushReplacementNamed(context, AppRoutes.otpVerification, arguments: state.email);
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
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1), 
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            child: Icon(Icons.lock_reset_rounded, color: Colors.white, size: 40.sp),
                          ),
                          SizedBox(height: 28.h),

                          Text('Récupération', style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5), textAlign: TextAlign.center),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text('Entrez votre adresse email pour recevoir un code de réinitialisation.',
                              style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.7), height: 1.5), textAlign: TextAlign.center),
                          ),
                          SizedBox(height: 40.h),

                          // Email field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Adresse Email', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                              SizedBox(height: 8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'votre@email.com',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15.sp),
                                      prefixIcon: Icon(Icons.email_outlined, color: Colors.white, size: 20.sp),
                                      filled: true, fillColor: Colors.white.withOpacity(0.1),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _emerald, width: 2)),
                                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _brick)),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                                      if (!value.contains('@')) return 'Format d\'email invalide';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          // Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading ? null : _handleForgotPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _emerald, foregroundColor: Colors.white,
                                disabledBackgroundColor: _emerald.withOpacity(0.5),
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                              ),
                              child: state is AuthLoading
                                  ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text('Envoyer le code', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                                      SizedBox(width: 8.w), Icon(Icons.arrow_forward_rounded, size: 18.sp),
                                    ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
