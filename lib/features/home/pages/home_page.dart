import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF121212),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: 24.sp, color: Colors.white),
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                  Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
                },
              ),
            ],
          ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 32.h),
                        Text(
                          'Welcome,',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.user.prenom} ${state.user.nom}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Card(
                          elevation: 2,
                          color: AppColors.darkSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Role',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Icon(
                                        _getRoleIcon(state.user.role),
                                        color: AppColors.primaryPurple,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Text(
                                      state.user.role.displayName,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: AppColors.primaryPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Center(
                          child: _buildProfileImage(state.user.profileImageUrl),
                        ),
                        // Debug: Always show referral code section for patients
                        if (state.user.role == UserRole.patient) ...[
                          SizedBox(height: 32.h),
                          Card(
                            elevation: 2,
                            color: AppColors.darkSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 1,
                              ),
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
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                          color: Colors.white,
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
                                                  : AppColors.darkTextSecondary,
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
                                      color: AppColors.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        // Display patient information for family members
                        if (state.user.role == UserRole.familyMember && 
                            state.user.patientNom != null && 
                            state.user.patientPrenom != null) ...[
                          SizedBox(height: 32.h),
                          Card(
                            elevation: 2,
                            color: AppColors.darkSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                width: 1,
                              ),
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
                                          Icons.person,
                                          color: AppColors.primaryPurple,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'Related Patient',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                          color: Colors.white,
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${state.user.patientPrenom} ${state.user.patientNom}',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'You are connected to this patient',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                  child: LoadingAnimationWidget.threeRotatingDots(
                    color: Theme.of(context).colorScheme.primary,
                    size: 40.sp,
                  ),
                );
              }
            },
          ),
        );
  }
  
  Widget _buildProfileImage(String? profileImageUrl) {
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return CircleAvatar(
        radius: 60.r,
        backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
        child: Icon(
          Icons.person,
          size: 60.sp,
          color: AppColors.primaryPurple,
        ),
      );
    }
    
    // Build the full image URL
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl.startsWith('http')
        ? profileImageUrl
        : '$baseUrl$profileImageUrl';
    
    return CircleAvatar(
      radius: 60.r,
      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 120.r,
          height: 120.r,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 60.sp,
                color: AppColors.primaryPurple,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primaryPurple,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.volontaire:
        return Icons.volunteer_activism;
      case UserRole.familyMember:
        return Icons.family_restroom;
    }
  }
}
