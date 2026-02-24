import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

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

const _indigo = Color(0xFF022F40);

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
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    ImageProvider? imageProvider;

    if (_imagePath != null && _imagePath!.isNotEmpty) {
      if (_imagePath!.startsWith('http') || _imagePath!.startsWith('/api')) {
        final imageUrl = _imagePath!.startsWith('http') ? _imagePath! : '$baseUrl$_imagePath';
        imageProvider = NetworkImage(imageUrl);
      } else {
        imageProvider = FileImage(File(_imagePath!));
      }
    }

    return Center(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 65.r,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: imageProvider,
              child: imageProvider == null 
                  ? Icon(Icons.person_rounded, size: 65.sp, color: Colors.white)
                  : null,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                  border: Border.all(color: _indigo, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, size: 20.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: _indigo,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text('Choisir une photo', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: Colors.white.withOpacity(0.7)),
                title: Text('Galerie', style: TextStyle(color: Colors.white)),
                onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery)),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: Colors.white.withOpacity(0.7)),
                title: Text('Appareil photo', style: TextStyle(color: Colors.white)),
                onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.camera)),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      if (_user == null) return;
      
      final event = _user!.role == UserRole.patient
          ? UpdatePatientProfileEvent(nom: _nomController.text.trim(), prenom: _prenomController.text.trim(), age: int.parse(_ageController.text.trim()), imagePath: _imagePath)
          : _user!.role == UserRole.volontaire
              ? UpdateVolontaireProfileEvent(nom: _nomController.text.trim(), prenom: _prenomController.text.trim(), age: int.parse(_ageController.text.trim()), imagePath: _imagePath)
              : UpdateFamilyMemberProfileEvent(nom: _nomController.text.trim(), prenom: _prenomController.text.trim(), imagePath: _imagePath);

      context.read<AuthBloc>().add(event);
    }
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14.sp),
                prefixIcon: Icon(prefixIcon, color: Colors.white, size: 20.sp),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: AppColors.emerald, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: AppColors.brick, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(gradient: _forestGradient),
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _forestGradient),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              Get.snackbar('Erreur', state.message, backgroundColor: AppColors.brick, colorText: Colors.white);
            } else if (state is AuthAuthenticated) {
              Get.snackbar('Succès', 'Profil mis à jour avec succès', backgroundColor: AppColors.emerald, colorText: Colors.white);
              Navigator.pop(context);
            }
          },
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text('Modifier le profil', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        SizedBox(height: 40.h),
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: _indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(label: 'Email', hintText: '', controller: _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                              SizedBox(height: 20.h),
                              _buildTextField(label: 'Nom', hintText: 'Entrez votre nom', controller: _nomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Le nom est requis' : null),
                              SizedBox(height: 20.h),
                              _buildTextField(label: 'Prénom', hintText: 'Entrez votre prénom', controller: _prenomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Le prénom est requis' : null),
                              if (_user!.role != UserRole.familyMember) ...[
                                SizedBox(height: 20.h),
                                _buildTextField(label: 'Âge', hintText: 'Entrez votre âge', controller: _ageController, prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'L\'âge est requis' : null),
                              ],
                              SizedBox(height: 32.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleUpdateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.emerald,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 18.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                    elevation: 0,
                                  ),
                                  child: Text('Enregistrer les modifications', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
