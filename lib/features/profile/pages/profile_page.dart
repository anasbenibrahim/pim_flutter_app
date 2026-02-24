import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../hopi/cubit/hopi_cubit.dart';

import '../../../core/theme/app_colors.dart';

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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _forestGradient),
        child: BlocBuilder<AuthBloc, AuthState>(
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
                        child: Text('Profile', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
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
                        icon: Icons.dark_mode_outlined, color: Colors.white,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: Get.find<ThemeController>().isDarkMode,
                          activeColor: AppColors.emerald,
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
                        onTap: () async {
                          context.read<HopiCubit>().reset();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('hopi_active_mood_state');
                          
                          if (context.mounted) {
                            context.read<AuthBloc>().add(const LogoutEvent());
                            Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String prenom, String nom, String email, String? profileImageUrl) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl != null
        ? (profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl')
        : null;

    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
            ),
            child: CircleAvatar(
              radius: 52.r,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null ? Icon(Icons.person_rounded, size: 48.sp, color: Colors.white) : null,
            ),
          ),
          SizedBox(height: 18.h),
          Text('$prenom $nom', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
          SizedBox(height: 4.h),
          Text(email, style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(text, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.5)));
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: _indigo.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15), 
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(icon, color: color == Colors.white ? Colors.white : color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: titleColor ?? Colors.white)),
            ),
            if (trailing != null) trailing
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, size: 22.sp, color: Colors.white.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
