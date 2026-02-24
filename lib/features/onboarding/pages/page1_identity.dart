import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/image_picker_widget.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart' as auth;

const _sapphire  = Color(0xFF0D6078);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);
const _indigo    = Color(0xFF022F40);

class Page1Identity extends StatefulWidget {
  final VoidCallback onNext;
  const Page1Identity({super.key, required this.onNext});

  @override
  State<Page1Identity> createState() => _Page1IdentityState();
}

class _Page1IdentityState extends State<Page1Identity> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(primary: _emerald, onPrimary: Colors.white, surface: const Color(0xFFE2F3F5), onSurface: _sapphire),
            dialogBackgroundColor: const Color(0xFFE2F3F5),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        context.read<OnboardingBloc>().add(DateNaissanceChanged(picked));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),

                    // ─── Progress Dots ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Container(
                        width: i == 0 ? 24.w : 8.w,
                        height: 8.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: i == 0 ? Colors.white : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      )),
                    ),
                    SizedBox(height: 28.h),

                    // ─── Header ───
                    Text(
                      'Créons votre profil 🌱',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Rejoignez HopeUp pour commencer votre parcours.\nVos données personnelles sont protégées.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ─── Avatar Picker ───
                    Center(
                      child: Stack(children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: ImagePickerWidget(
                              onImageSelected: (p) {
                                if (p != null) context.read<OnboardingBloc>().add(ImagePathChanged(p));
                              }
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0, 
                          child: Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(color: _emerald, shape: BoxShape.circle, border: Border.all(color: _sapphire, width: 2)),
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(height: 24.h),

                    // ─── Prénom & Nom ───
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _field('Prénom', 'Jean', _prenomController, icon: Icons.person_outline_rounded,
                            onChanged: (v) => context.read<OnboardingBloc>().add(PrenomChanged(v.trim()))),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: _field('Nom', 'Dupont', _nomController,
                            onChanged: (v) => context.read<OnboardingBloc>().add(NomChanged(v.trim()))),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // ─── Privacy Toggle ───
                    Row(
                      children: [
                        Text(
                          state.prenamePrivate ? '🔒 Prénom masqué' : '🌍 Prénom public',
                          style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.read<OnboardingBloc>().add(const PrenamePrivacyToggled()),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 52.w,
                            height: 28.h,
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: state.prenamePrivate ? _emerald : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 250),
                              alignment: state.prenamePrivate ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                width: 22.w,
                                height: 22.h,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // ─── Username ───
                    _field(
                      'Nom d\'utilisateur', '@votre_pseudo', _usernameController,
                      icon: Icons.alternate_email_rounded,
                      onChanged: (v) => context.read<OnboardingBloc>().add(UsernameChanged(v.trim())),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (v.length < 3) return 'Minimum 3 caractères';
                        return null;
                      },
                    ),
                    SizedBox(height: 18.h),

                    // ─── Date of Birth ───
                    _label('Date de Naissance'),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        decoration: _boxDecoration,
                        child: Row(children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18.sp),
                          SizedBox(width: 12.w),
                          Text(
                            state.dateNaissance != null ? DateFormat('dd/MM/yyyy').format(state.dateNaissance!) : 'Sélectionner',
                            style: TextStyle(fontSize: 15.sp, color: state.dateNaissance != null ? Colors.white : Colors.white.withOpacity(0.5)),
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // ─── Email ───
                    _field('Email', 'jean.dupont@email.com', _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => context.read<OnboardingBloc>().add(EmailChanged(v.trim())),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (!v.contains('@')) return 'Email invalide';
                        return null;
                      },
                    ),
                    SizedBox(height: 18.h),

                    // ─── Password ───
                    _label('Mot de passe'),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(fontSize: 15.sp, color: Colors.white),
                      decoration: _inputDeco('••••••••', Icons.lock_outline_rounded).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white.withOpacity(0.5), size: 20.sp),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      onChanged: (v) => context.read<OnboardingBloc>().add(PasswordChanged(v)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (v.length < 6) return 'Mini 6 caractères';
                        return null;
                      },
                    ),
                    SizedBox(height: 36.h),

                    // ─── CTA ───
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (state.dateNaissance == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Veuillez sélectionner votre date de naissance'),
                                  backgroundColor: _brick,
                                ),
                              );
                              return;
                            }
                            widget.onNext();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emerald,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Continuer', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward_rounded, size: 18.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
  );

  Widget _field(String label, String hint, TextEditingController ctrl, {IconData? icon, TextInputType? keyboardType, String? Function(String?)? validator, void Function(String)? onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      SizedBox(height: 8.h),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.sp, color: Colors.white),
        decoration: _inputDeco(hint, icon),
        validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Requis' : null,
        onChanged: onChanged,
      ),
    ]);
  }

  BoxDecoration get _boxDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
  );

  InputDecoration _inputDeco(String hint, [IconData? icon]) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15.sp),
    prefixIcon: icon != null ? Icon(icon, color: Colors.white, size: 20.sp) : null,
    filled: true,
    fillColor: Colors.white.withOpacity(0.1),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _emerald, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: _brick)),
  );
}
