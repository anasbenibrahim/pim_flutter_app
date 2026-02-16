import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/image_picker_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/models/addiction_type.dart';
import '../../../core/routes/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});
  
  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();

  DateTime? _dateNaissance;
  DateTime? _sobrietyDate;
  AddictionType? _selectedAddiction;
  String? _imagePath;
  bool _obscurePassword = true;
  int _currentStep = 0;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context, bool isNaissance) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isNaissance) {
          _dateNaissance = picked;
        } else {
          _sobrietyDate = picked;
        }
      });
    }
  }
  
  void _goToStep2() {
    if (_formKeyStep1.currentState!.validate()) {
      setState(() => _currentStep = 1);
    }
  }

  void _handleRegister() {
    if (_formKeyStep2.currentState!.validate()) {
      if (_dateNaissance == null) {
        Get.snackbar(
          'Error',
          'Please select date of birth',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 8.r,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      if (_sobrietyDate == null) {
        Get.snackbar(
          'Error',
          'Please select sobriety date',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 8.r,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      if (_selectedAddiction == null) {
        Get.snackbar(
          'Error',
          'Please select addiction type',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          borderRadius: 8.r,
          duration: const Duration(seconds: 3),
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
          sobrietyDate: _sobrietyDate!,
          addiction: _selectedAddiction!,
          imagePath: _imagePath,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Register',
        onBackPressed: _currentStep == 1
            ? () => setState(() => _currentStep = 0)
            : null,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
              duration: const Duration(seconds: 3),
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
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _currentStep == 0 ? _buildStep1(context, state) : _buildStep2(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1(BuildContext context, AuthState state) {
    return Form(
      key: _formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Étape 1 sur 2',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: ImagePickerWidget(
              onImageSelected: (path) {
                setState(() {
                  _imagePath = path;
                });
              },
            ),
          ),
          SizedBox(height: 28.h),
          CustomTextField(
            label: 'Nom',
            hint: 'Enter your last name',
            controller: _nomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your nom';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'Prenom',
            hint: 'Enter your first name',
            controller: _prenomController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your prenom';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'Age',
            hint: 'Enter your age',
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 150) {
                return 'Please enter a valid age';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'Continuer',
            onPressed: state is AuthLoading ? null : _goToStep2,
            isLoading: false,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, AuthState state) {
    return Form(
      key: _formKeyStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Text(
            'Informations de récupération',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Étape 2 sur 2',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 24.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date de Naissance',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'sans-serif',
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _dateNaissance != null
                        ? DateFormat('yyyy-MM-dd').format(_dateNaissance!)
                        : 'Select date of birth',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _dateNaissance != null
                          ? const Color(0xFF333333)
                          : const Color(0xFF666666),
                      fontWeight: FontWeight.normal,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobriety Date',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'sans-serif',
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _sobrietyDate != null
                        ? DateFormat('yyyy-MM-dd').format(_sobrietyDate!)
                        : 'Select sobriety date',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: _sobrietyDate != null
                          ? const Color(0xFF333333)
                          : const Color(0xFF666666),
                      fontWeight: FontWeight.normal,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomDropdownField<AddictionType>(
            label: 'Addiction Type',
            hint: 'Select addiction type',
            value: _selectedAddiction,
            items: AddictionType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF333333),
                    fontFamily: 'sans-serif',
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAddiction = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select addiction type';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF666666),
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'Register',
            onPressed: state is AuthLoading ? null : _handleRegister,
            isLoading: state is AuthLoading,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
