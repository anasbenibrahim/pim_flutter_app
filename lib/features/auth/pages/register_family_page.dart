import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/image_picker_widget.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterFamilyPage extends StatefulWidget {
  const RegisterFamilyPage({super.key});
  
  @override
  State<RegisterFamilyPage> createState() => _RegisterFamilyPageState();
}

class _RegisterFamilyPageState extends State<RegisterFamilyPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _referralKeyController = TextEditingController();
  
  String? _imagePath;
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _referralKeyController.dispose();
    super.dispose();
  }
  
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterFamilyMemberEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          referralKey: _referralKeyController.text.trim(),
          imagePath: _imagePath,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Inscription Famille',
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
          } else if (state is RegistrationOtpSentState) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.registerOtpVerification,
              arguments: {
                'email': state.email,
                'userRole': state.userRole,
                'imagePath': state.imagePath,
              },
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soutenir un proche',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getPremiumText(context),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Accompagnez ceux qui vous sont chers dans leur parcours.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.getPremiumTextSecondary(context),
                  ),
                ),
                SizedBox(height: 32.h),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryPurple, width: 2),
                        ),
                        child: ImagePickerWidget(
                          onImageSelected: (path) => setState(() => _imagePath = path),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: PremiumTextField(
                                controller: _prenomController,
                                label: 'Prénom',
                                hintText: 'Jean',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (value) => (value == null || value.isEmpty) ? 'Requis' : null,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: PremiumTextField(
                                controller: _nomController,
                                label: 'Nom',
                                hintText: 'Dupont',
                                validator: (value) => (value == null || value.isEmpty) ? 'Requis' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        PremiumTextField(
                          controller: _referralKeyController,
                          label: 'Code de parrainage',
                          hintText: 'Code du patient',
                          prefixIcon: Icons.vpn_key_outlined,
                          validator: (value) => (value == null || value.isEmpty) ? 'Code requis' : null,
                        ),
                        SizedBox(height: 20.h),
                        PremiumTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'famille@email.com',
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
                            if (value == null || value.isEmpty) return 'Requis';
                            if (value.length < 6) return 'Mini 6 caractères';
                            return null;
                          },
                        ),
                        SizedBox(height: 32.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _handleRegister,
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
                                : Text('S\'inscrire', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
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
