import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/menu_list_tile.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/models/user_role.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _buildProfileImage(String? profileImageUrl) {
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: 50.r,
        backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
        child: Icon(
          Icons.person,
          size: 50.sp,
          color: AppColors.primaryPurple,
        ),
      );
    }
    
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl.startsWith('http')
        ? profileImageUrl
        : '$baseUrl$profileImageUrl';
    
    return CircleAvatar(
      radius: 50.r,
      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Handle error if image fails to load
      },
      child: profileImageUrl.isEmpty
          ? Icon(
              Icons.person,
              size: 50.sp,
              color: AppColors.primaryPurple,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CustomAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 32.h),
                  // Profile Image
                  Center(
                    child: _buildProfileImage(state.user.profileImageUrl),
                  ),
                  SizedBox(height: 24.h),
                  // User Name
                  Text(
                    '${state.user.prenom} ${state.user.nom}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      color: AppColors.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // User Email
                  Text(
                    state.user.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  // Referral Code Section (for patients)
                  if (state.user.role == UserRole.patient) ...[
                    SizedBox(height: 32.h),
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.share,
                                    color: AppColors.primaryPurple,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Your Referral Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      state.user.referralCode ?? 'Loading...',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: state.user.referralCode != null 
                                            ? AppColors.primaryPurple 
                                            : AppColors.lightTextSecondary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  if (state.user.referralCode != null)
                                    IconButton(
                                      icon: Icon(
                                        Icons.copy,
                                        color: AppColors.primaryPurple,
                                        size: 20.sp,
                                      ),
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: state.user.referralCode!),
                                        );
                                        Get.snackbar(
                                          'Success',
                                          'Referral code copied!',
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: AppColors.primaryPurple,
                                          colorText: Colors.white,
                                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                          borderRadius: 8.r,
                                          duration: const Duration(seconds: 3),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Share this code with your family members so they can join',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 40.h),
                  // Menu Items
                  if (state.user.role == UserRole.patient)
                    MenuListTile(
                      icon: Icons.emoji_events_outlined,
                      title: 'My Badges',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.myBadges),
                      showArrow: true,
                    ),
                  MenuListTile(
                    icon: Icons.person_outline,
                    title: 'Manage Profile',
                    showArrow: false,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.updateProfile,
                        arguments: {'user': state.user},
                      );
                    },
                  ),
                  MenuListTile(
                    icon: Icons.tune,
                    title: 'Customize My Level',
                    onTap: null, // Static, not clickable
                    showArrow: false,
                  ),
                  MenuListTile(
                    icon: Icons.notifications_outlined,
                    title: 'Manage Notification',
                    onTap: null, // Static, not clickable
                    showArrow: false,
                  ),
                  MenuListTile(
                    icon: Icons.help_outline,
                    title: 'FAQ',
                    onTap: null, // Static, not clickable
                    showArrow: false,
                  ),
                  MenuListTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: null, // Static, not clickable
                    showArrow: false,
                  ),
                  MenuListTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    iconColor: Colors.red,
                    showArrow: false,
                    onTap: () {
                      context.read<AuthBloc>().add(const LogoutEvent());
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.getStarted,
                        (route) => false,
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
              ),
            );
          }
        },
      ),
    );
  }
}
