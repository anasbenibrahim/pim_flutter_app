import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/social_login_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Connexion',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bon retour parmi nous',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPremiumText(context),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Connectez-vous pour continuer votre parcours.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.getPremiumTextSecondary(context),
                  ),
                ),
                SizedBox(height: 32.h),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        PremiumTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'votre@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'L\'email est requis';
                            if (!value.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                        PremiumTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Le mot de passe est requis';
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(color: AppColors.primaryPurple, fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleLogin,
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
                                : Text('Se Connecter', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('Ou continuer avec', style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                    ),
                    Expanded(child: Divider(color: Colors.white10)),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: 'assets/images/google.png',
                        label: 'Google',
                        onPressed: () => context.read<AuthBloc>().add(const GoogleSignInEvent()),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _SocialButton(
                        icon: 'assets/images/apple.png',
                        label: 'Apple',
                        onPressed: () => context.read<AuthBloc>().add(const AppleSignInEvent()),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48.h),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.roleSelection),
                    child: RichText(
                      text: TextSpan(
                        text: 'Pas encore de compte ? ',
                        style: TextStyle(color: AppColors.getPremiumTextSecondary(context), fontSize: 14.sp),
                        children: [
                          TextSpan(
                            text: 'S\'inscrire',
                            style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.getGlassColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.getGlassBorder(context)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, height: 24.h),
              SizedBox(width: 12.w),
              Text(label, style: TextStyle(color: AppColors.getPremiumText(context), fontWeight: FontWeight.w500, fontSize: 14.sp)),
            ],
          ),
        ),
      ),
    );
  }
}
