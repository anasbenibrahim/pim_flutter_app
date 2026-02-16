import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _ageController;
  
  String? _imagePath;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _ageController = TextEditingController();
    
    // Get user from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['user'] != null) {
        setState(() {
          _user = args['user'] as UserModel;
          _loadUserData();
        });
      }
    });
  }

  void _loadUserData() {
    if (_user == null) return;
    
    _emailController.text = _user!.email;
    _nomController.text = _user!.nom;
    _prenomController.text = _user!.prenom;
    if (_user!.age != null) {
      _ageController.text = _user!.age.toString();
    }
    _imagePath = _user!.profileImageUrl;
    
    // For patients, we would need to load additional data from backend
    // For now, we'll just show the basic fields
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    super.dispose();
  }


  Widget _buildProfileImage() {
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      // Check if it's a network URL or local path
      if (_imagePath!.startsWith('http') || _imagePath!.startsWith('/')) {
        final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
        final imageUrl = _imagePath!.startsWith('http')
            ? _imagePath!
            : '$baseUrl$_imagePath';
        
        return CircleAvatar(
          radius: 60.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle error
          },
        );
      } else {
        // Local file path
        return CircleAvatar(
          radius: 60.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: Image.asset(_imagePath!).image,
        );
      }
    }
    
    return CircleAvatar(
      radius: 60.r,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: const Color(0xFF666666),
      ),
    );
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      if (_user == null) return;
      
      // Dispatch update patient profile event (without dateNaissance, sobrietyDate, addiction)
      if (_user!.role == UserRole.patient) {
        context.read<AuthBloc>().add(
          UpdatePatientProfileEvent(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            imagePath: _imagePath,
          ),
        );
      } else if (_user!.role == UserRole.volontaire) {
        // Dispatch update volontaire profile event
        context.read<AuthBloc>().add(
          UpdateVolontaireProfileEvent(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            imagePath: _imagePath,
          ),
        );
      } else if (_user!.role == UserRole.familyMember) {
        // Dispatch update family member profile event
        context.read<AuthBloc>().add(
          UpdateFamilyMemberProfileEvent(
            nom: _nomController.text.trim(),
            prenom: _prenomController.text.trim(),
            imagePath: _imagePath,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'Update Profile'),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Update Profile'),
      body: BlocListener<AuthBloc, AuthState>(
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
          } else if (state is AuthAuthenticated) {
            Get.snackbar(
              'Success',
              'Profile updated successfully',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              borderRadius: 8.r,
              duration: const Duration(seconds: 3),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Show image picker modal
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(25.r),
                                  topRight: Radius.circular(25.r),
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                                      width: 40.w,
                                      height: 4.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(2.r),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                                      child: Text(
                                        'Select Image Source',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: const Color(0xFF333333),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'sans-serif',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final ImagePicker picker = ImagePicker();
                                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                          if (image != null && mounted) {
                                            setState(() {
                                              _imagePath = image.path;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(25.r),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 48.w,
                                                height: 48.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12.r),
                                                ),
                                                child: Icon(
                                                  Icons.photo_library,
                                                  size: 28.sp,
                                                  color: const Color(0xFF333333),
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Text(
                                                'Gallery',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: const Color(0xFF333333),
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'sans-serif',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          final ImagePicker picker = ImagePicker();
                                          final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                          if (image != null && mounted) {
                                            setState(() {
                                              _imagePath = image.path;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(25.r),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 48.w,
                                                height: 48.h,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12.r),
                                                ),
                                                child: Icon(
                                                  Icons.photo_camera,
                                                  size: 28.sp,
                                                  color: const Color(0xFF333333),
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Text(
                                                'Camera',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: const Color(0xFF333333),
                                                  fontWeight: FontWeight.normal,
                                                  fontFamily: 'sans-serif',
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
                              ),
                            ),
                          );
                        },
                        child: _buildProfileImage(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Show image picker modal (same as above)
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25.r),
                                    topRight: Radius.circular(25.r),
                                  ),
                                ),
                                child: SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                                        width: 40.w,
                                        height: 4.h,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(2.r),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                                        child: Text(
                                          'Select Image Source',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: const Color(0xFF333333),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'sans-serif',
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            final ImagePicker picker = ImagePicker();
                                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                            if (image != null && mounted) {
                                              setState(() {
                                                _imagePath = image.path;
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25.r),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.w,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48.w,
                                                  height: 48.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(12.r),
                                                  ),
                                                  child: Icon(
                                                    Icons.photo_library,
                                                    size: 28.sp,
                                                    color: const Color(0xFF333333),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                                Text(
                                                  'Gallery',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: const Color(0xFF333333),
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: 'sans-serif',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            final ImagePicker picker = ImagePicker();
                                            final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                            if (image != null && mounted) {
                                              setState(() {
                                                _imagePath = image.path;
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25.r),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.w,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48.w,
                                                  height: 48.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(12.r),
                                                  ),
                                                  child: Icon(
                                                    Icons.photo_camera,
                                                    size: 28.sp,
                                                    color: const Color(0xFF333333),
                                                  ),
                                                ),
                                                SizedBox(width: 16.w),
                                                Text(
                                                  'Camera',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: const Color(0xFF333333),
                                                    fontWeight: FontWeight.normal,
                                                    fontFamily: 'sans-serif',
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
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.w,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                // Email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email cannot be changed
                ),
                SizedBox(height: 20.h),
                // Nom
                CustomTextField(
                  label: 'Nom',
                  controller: _nomController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                // Prenom
                CustomTextField(
                  label: 'Prenom',
                  controller: _prenomController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prenom is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                // Age (for Patient and Volontaire)
                if (_user!.role == UserRole.patient || _user!.role == UserRole.volontaire) ...[
                  CustomTextField(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 150) {
                        return 'Age must be between 1 and 150';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
                // Update Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'Update Profile',
                      onPressed: state is AuthLoading ? null : _handleUpdateProfile,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
