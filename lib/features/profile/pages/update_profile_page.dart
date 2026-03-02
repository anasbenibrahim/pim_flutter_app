import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isLocalImage = false;
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
    final url = _user!.profileImageUrl;
    if (url != null && url.isNotEmpty && !url.startsWith('null')) {
      _imagePath = url;
      _isLocalImage = false;
    }
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
    final theme = Theme.of(context);
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    ImageProvider? imageProvider;

    if (_imagePath != null && _imagePath!.isNotEmpty) {
      if (_isLocalImage) {
        final file = File(_imagePath!);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      } else {
        final url = _imagePath!;
        final imageUrl = url.startsWith('http') ? url : '$baseUrl${url.startsWith('/') ? url : '/$url'}';
        imageProvider = NetworkImage(imageUrl);
      }
    }

    return Center(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15), width: 3),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 130.r,
                height: 130.r,
                child: imageProvider != null
                    ? Image(
                        image: imageProvider,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderAvatar(),
                      )
                    : _placeholderAvatar(),
              ),
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
                  color: theme.colorScheme.primary,
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

  Widget _buildFormField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.getGlassColor(context),
            prefixIcon: Icon(prefixIcon, size: 20.sp, color: theme.colorScheme.primary),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.getGlassBorder(context))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.getGlassBorder(context))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: const BorderSide(color: AppColors.error)),
          ),
        ),
      ],
    );
  }

  Widget _placeholderAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.getGlassColor(context),
      child: Icon(Icons.person_rounded, size: 65.sp, color: Theme.of(context).colorScheme.primary),
    );
  }

  Future<void> _pickImage() async {
    final theme = Theme.of(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text('Choisir une photo', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: theme.colorScheme.primary),
              title: Text('Galerie', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
              onTap: () async => Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery)),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: theme.colorScheme.primary),
              title: Text('Appareil photo', style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
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
        _isLocalImage = true;
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
    final theme = Theme.of(context);
    if (_user == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
                    boxShadow: theme.brightness == Brightness.dark ? null : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFormField(context, 'Email', _emailController, prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, readOnly: true),
                      SizedBox(height: 20.h),
                      _buildFormField(context, 'Nom', _nomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v?.isEmpty ?? true ? 'Le nom est requis' : null),
                      SizedBox(height: 20.h),
                      _buildFormField(context, 'Prénom', _prenomController, prefixIcon: Icons.person_outline_rounded, validator: (v) => v?.isEmpty ?? true ? 'Le prénom est requis' : null),
                      if (_user!.role != UserRole.familyMember) ...[
                        SizedBox(height: 20.h),
                        _buildFormField(context, 'Âge', _ageController, prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty ?? true ? 'L\'âge est requis' : null),
                      ],
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _handleUpdateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            elevation: 0,
                          ),
                          child: Text('Enregistrer les modifications', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
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
