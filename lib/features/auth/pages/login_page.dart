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
const _indigo    = Color(0xFF022F40);
const _brick     = Color(0xFFF9623E);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    Get.snackbar(
                      'Erreur',
                      state.message,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: _brick,
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
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Logo ───
                        Center(
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            child: Icon(Icons.spa_rounded, size: 28.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // ─── Header ───
                        Text(
                          'Bon retour\nparmi nous 👋',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Connectez-vous pour continuer votre parcours.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 36.h),

                        // ─── Form ───
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField(
                                label: 'Adresse Email',
                                hint: 'votre@email.com',
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'L\'email est requis';
                                  if (!value.contains('@')) return 'Email invalide';
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),

                              _buildTextField(
                                label: 'Mot de passe',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Le mot de passe est requis';
                                  return null;
                                },
                              ),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _emerald,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: _emerald.withOpacity(0.5),
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: state is AuthLoading
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.h,
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Se Connecter',
                                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(width: 8.w),
                                            Icon(Icons.arrow_forward_rounded, size: 18.sp),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // ─── Divider ───
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Ou continuer avec',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // ─── Social Buttons ───
                        Row(
                          children: [
                            Expanded(
                              child: _SocialBtn(
                                icon: 'assets/images/google.png',
                                label: 'Google',
                                onTap: () => context.read<AuthBloc>().add(const GoogleSignInEvent()),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: _SocialBtn(
                                icon: 'assets/images/apple.png',
                                label: 'Apple',
                                onTap: () => context.read<AuthBloc>().add(const AppleSignInEvent()),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 40.h),

                        // ─── Sign Up Link ───
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.roleSelection),
                            child: RichText(
                              text: TextSpan(
                                text: 'Pas encore de compte ? ',
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14.sp),
                                children: [
                                  TextSpan(
                                    text: 'S\'inscrire',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              validator: validator,
              style: TextStyle(fontSize: 15.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15.sp),
                prefixIcon: Icon(icon, color: Colors.white, size: 20.sp),
                suffixIcon: isPassword ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 20.sp,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ) : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: _emerald, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: _brick),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 22.h),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
