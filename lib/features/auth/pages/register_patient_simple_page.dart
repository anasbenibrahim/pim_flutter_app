import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/image_picker_widget.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPatientSimplePage extends StatefulWidget {
  const RegisterPatientSimplePage({super.key});
  
  @override
  State<RegisterPatientSimplePage> createState() => _RegisterPatientSimplePageState();
}

class _RegisterPatientSimplePageState extends State<RegisterPatientSimplePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();
  
  DateTime? _dateNaissance;
  String? _imagePath;
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryPurple,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F001E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateNaissance = picked;
        final age = DateTime.now().year - picked.year;
        if (DateTime.now().month < picked.month || 
            (DateTime.now().month == picked.month && DateTime.now().day < picked.day)) {
          _ageController.text = (age - 1).toString();
        } else {
          _ageController.text = age.toString();
        }
      });
    }
  }
  
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_dateNaissance == null) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner votre date de naissance',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 12.r,
        );
        return;
      }
      
      context.read<AuthBloc>().add(
        RegisterPatientEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          age: int.parse(_ageController.text),
          dateNaissance: _dateNaissance!,
          sobrietyDate: null,
          addiction: null,
          imagePath: _imagePath,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Inscription Patient',
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
                  'Créer votre compte',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Rejoignez notre communauté premium dès aujourd\'hui.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date de Naissance',
                              style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, color: AppColors.primaryPurple, size: 20.sp),
                                    SizedBox(width: 12.w),
                                    Text(
                                      _dateNaissance != null
                                          ? DateFormat('dd/MM/yyyy').format(_dateNaissance!)
                                          : 'Sélectionner',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: _dateNaissance != null ? Colors.white : Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        PremiumTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'jean.dupont@email.com',
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
                              color: Colors.white38,
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
