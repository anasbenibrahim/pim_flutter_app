import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/menu_list_tile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/models/user_role.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Profil',
        showBackButton: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                   SizedBox(height: 20.h),
                  _buildProfileHeader(context, state.user.prenom, state.user.nom, state.user.email, state.user.profileImageUrl),
                  SizedBox(height: 40.h),
                  
                  const PremiumSectionTitle(title: 'Compte', icon: Icons.person_outline_rounded),
                  MenuListTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Modifier le profil',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.updateProfile,
                        arguments: {'user': state.user},
                      );
                    },
                  ),
                  
                  const PremiumSectionTitle(title: 'Préférences', icon: Icons.tune_rounded),
                  Obx(() => MenuListTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Mode Sombre',
                    showArrow: false,
                    trailing: Switch(
                      value: Get.find<ThemeController>().isDarkMode,
                      activeColor: AppColors.primaryPurple,
                      onChanged: (val) => Get.find<ThemeController>().toggleTheme(),
                    ),
                  )),
                  MenuListTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: null, // Prochainement
                  ),
                  
                  const PremiumSectionTitle(title: 'Assistance', icon: Icons.help_outline_rounded),
                  MenuListTile(
                    icon: Icons.info_outline_rounded,
                    title: 'À propos',
                    onTap: null, // Prochainement
                  ),
                  
                  SizedBox(height: 24.h),
                  MenuListTile(
                    icon: Icons.logout_rounded,
                    title: 'Déconnexion',
                    iconColor: Colors.redAccent,
                    onTap: () {
                      context.read<AuthBloc>().add(const LogoutEvent());
                      Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
                    },
                  ),
                  SizedBox(height: 50.h),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String prenom, String nom, String email, String? profileImageUrl) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl != null 
        ? (profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl')
        : null;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5), width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60.r,
            backgroundColor: AppColors.getGlassColor(context),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null 
                ? Icon(Icons.person_rounded, size: 60.sp, color: AppColors.primaryPurple)
                : null,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          '$prenom $nom',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.getPremiumText(context),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          email,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.getPremiumTextSecondary(context),
          ),
        ),
      ],
    );
  }
}
