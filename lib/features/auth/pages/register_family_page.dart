import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/image_picker_widget.dart';
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

const _sapphire  = Color(0xFF0D6078);
const _sunflower = Color(0xFFF8C929);
const _brick     = Color(0xFFF9623E);

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
              title: Text(
                'Inscription Famille',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
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
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soutenir un proche',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Accompagnez ceux qui vous sont chers dans leur parcours.',
                          style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.7)),
                        ),
                        SizedBox(height: 28.h),

                        // Avatar
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ImagePickerWidget(
                                    onImageSelected: (path) => setState(() => _imagePath = path),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(7.w),
                                  decoration: const BoxDecoration(color: _sunflower, shape: BoxShape.circle),
                                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28.h),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _field('Prénom', 'Jean', _prenomController, icon: Icons.person_outline_rounded, validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                                  SizedBox(width: 14.w),
                                  Expanded(child: _field('Nom', 'Dupont', _nomController, validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null)),
                                ],
                              ),
                              SizedBox(height: 18.h),
                              _field('Code de parrainage', 'Code du patient', _referralKeyController, icon: Icons.vpn_key_outlined, validator: (v) => (v == null || v.isEmpty) ? 'Code requis' : null),
                              SizedBox(height: 18.h),
                              _field('Email', 'famille@email.com', _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) {
                                if (v == null || v.isEmpty) return 'L\'email est requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              }),
                              SizedBox(height: 18.h),

                              // Password
                              Text('Mot de passe', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
                              SizedBox(height: 8.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14.r),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                    decoration: _inputDeco('••••••••', Icons.lock_outline_rounded).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                          color: Colors.white.withOpacity(0.5),
                                          size: 20.sp,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Requis';
                                      if (v.length < 6) return 'Mini 6 caractères';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),

                              // Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _sunflower,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: _sunflower.withOpacity(0.5),
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                    elevation: 0,
                                  ),
                                  child: state is AuthLoading
                                      ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('S\'inscrire', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _sapphire)),
                                            SizedBox(width: 8.w),
                                            Icon(Icons.arrow_forward_rounded, size: 18.sp, color: _sapphire),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
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

  Widget _field(String label, String hint, TextEditingController ctrl, {IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: ctrl,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 15.sp, color: Colors.white),
              decoration: _inputDeco(hint, icon),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint, [IconData? icon]) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15.sp),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white, size: 20.sp) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _sunflower, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _brick)),
    );
  }
}
