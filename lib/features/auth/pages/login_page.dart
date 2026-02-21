import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ─── HopeUp Palette ───
const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
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
      backgroundColor: _linen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _indigo, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
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
                      color: _sapphire.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.spa_rounded, size: 28.sp, color: _sapphire),
                  ),
                ),
                SizedBox(height: 32.h),

                // ─── Header ───
                Text(
                  'Bon retour\nparmi nous 👋',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: _indigo,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Connectez-vous pour continuer votre parcours.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _indigo.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: 36.h),

                // ─── Form ───
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Label
                      Text(
                        'Adresse Email',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _indigo.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 15.sp, color: _indigo),
                        decoration: _inputDecoration(
                          hint: 'votre@email.com',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'L\'email est requis';
                          if (!value.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Password Label
                      Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _indigo.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 15.sp, color: _indigo),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: _indigo.withOpacity(0.3),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
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
                              color: _sapphire,
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
                            backgroundColor: _sapphire,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _sapphire.withOpacity(0.5),
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
                    Expanded(child: Divider(color: _indigo.withOpacity(0.1))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Ou continuer avec',
                        style: TextStyle(color: _indigo.withOpacity(0.35), fontSize: 13.sp),
                      ),
                    ),
                    Expanded(child: Divider(color: _indigo.withOpacity(0.1))),
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
                        style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp),
                        children: [
                          TextSpan(
                            text: 'S\'inscrire',
                            style: TextStyle(
                              color: _sapphire,
                              fontWeight: FontWeight.w700,
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
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _indigo.withOpacity(0.25), fontSize: 15.sp),
      prefixIcon: Icon(icon, color: _sapphire, size: 20.sp),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _indigo.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _indigo.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _sapphire, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _brick),
      ),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _indigo.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 22.h),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: _indigo,
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
