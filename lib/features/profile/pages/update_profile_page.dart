import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';
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
        // Assume local path if it's from image picker
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
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 65.r,
              backgroundColor: AppColors.getGlassColor(context),
              backgroundImage: imageProvider,
              child: imageProvider == null 
                  ? Icon(Icons.person_rounded, size: 65.sp, color: AppColors.primaryPurple)
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
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
      builder: (context) => GlassCard(
        borderRadius: 25.r,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.getPremiumTextSecondary(context).withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text('Choisir une photo', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context))),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.getPremiumTextSecondary(context)),
              title: Text('Galerie', style: TextStyle(color: AppColors.getPremiumText(context))),
              onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery)),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: AppColors.getPremiumTextSecondary(context)),
              title: Text('Appareil photo', style: TextStyle(color: AppColors.getPremiumText(context))),
              onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.camera)),
            ),
            SizedBox(height: 24.h),
          ],
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

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const PremiumScaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple)));
    }

    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Modifier le profil',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            Get.snackbar('Erreur', state.message, backgroundColor: Colors.redAccent, colorText: Colors.white);
          } else if (state is AuthAuthenticated) {
            Get.snackbar('Succès', 'Profil mis à jour avec succès', backgroundColor: Colors.green, colorText: Colors.white);
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(),
                SizedBox(height: 40.h),
                GlassCard(
                  child: Column(
                    children: [
                      PremiumTextField(label: 'Email', hintText: '', controller: _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 20.h),
                      PremiumTextField(label: 'Nom', hintText: 'Entrez votre nom', controller: _nomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Le nom est requis' : null),
                      SizedBox(height: 20.h),
                      PremiumTextField(label: 'Prénom', hintText: 'Entrez votre prénom', controller: _prenomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Le prénom est requis' : null),
                      if (_user!.role != UserRole.familyMember) ...[
                        SizedBox(height: 20.h),
                        PremiumTextField(label: 'Âge', hintText: 'Entrez votre âge', controller: _ageController, prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'L\'âge est requis' : null),
                      ],
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleUpdateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
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
    );
  }
}
