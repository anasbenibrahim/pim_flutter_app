import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

import '../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Center(
                      child: Text('Profile', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                    ),
                    SizedBox(height: 28.h),

                    // Avatar + Info
                    _buildHeader(context, state.user.prenom, state.user.nom, state.user.email, state.user.profileImageUrl),
                    SizedBox(height: 36.h),

                    // Account Section
                    _sectionTitle(context, 'Account'),
                    SizedBox(height: 10.h),
                    _tile(
                      context,
                      icon: Icons.edit_note_rounded, color: AppColors.sapphire,
                      title: 'Edit Profile',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.updateProfile, arguments: {'user': state.user}),
                    ),
                    SizedBox(height: 24.h),

                    // Preferences Section
                    _sectionTitle(context, 'Preferences'),
                    SizedBox(height: 10.h),
                    Obx(() => _tile(
                      context,
                      icon: Icons.dark_mode_outlined, color: theme.colorScheme.onSurface,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: Get.find<ThemeController>().isDarkMode,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (_) => Get.find<ThemeController>().toggleTheme(),
                      ),
                    )),
                    SizedBox(height: 8.h),
                    _tile(context, icon: Icons.notifications_none_rounded, color: AppColors.emerald, title: 'Notifications'),
                    SizedBox(height: 24.h),

                    // Support Section
                    _sectionTitle(context, 'Support'),
                    SizedBox(height: 10.h),
                    _tile(context, icon: Icons.info_outline_rounded, color: AppColors.sapphire, title: 'About HopeUp'),
                    SizedBox(height: 24.h),

                    // Logout
                    _tile(
                      context,
                      icon: Icons.logout_rounded, color: AppColors.brick,
                      title: 'Log Out', titleColor: AppColors.brick,
                      onTap: () {
                        context.read<AuthBloc>().add(const LogoutEvent());
                        Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary, strokeWidth: 2));
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String prenom, String nom, String email, String? profileImageUrl) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl != null
        ? (profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl')
        : null;

    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15), width: 3),
            ),
            child: CircleAvatar(
              radius: 52.r,
              backgroundColor: theme.colorScheme.surface,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? Icon(Icons.person_rounded, size: 48.sp, color: theme.colorScheme.primary) : null,
            ),
          ),
          SizedBox(height: 18.h),
          Text('$prenom $nom', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: -0.5)),
          SizedBox(height: 4.h),
          Text(email, style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)));
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: titleColor ?? theme.colorScheme.onSurface)),
            ),
            if (trailing != null) trailing
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 22.sp, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
