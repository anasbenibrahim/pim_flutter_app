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
import '../../../core/models/achievement_badge.dart';
import '../../../core/models/weekly_achievement_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: 20.sp,
                color: AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.lightText),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: 24.sp, color: AppColors.lightText),
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.getStarted,
                    (route) => false,
                  );
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
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${state.user.prenom} ${state.user.nom}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            color: AppColors.lightText,
                          ),
                        ),
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
                                Text(
                                  'Your Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: AppColors.lightText,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10.r),
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
                                      style: TextStyle(
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
                        // Achievement hebdomadaire pour les patients
                        if (state.user.role == UserRole.patient) ...[
                          SizedBox(height: 24.h),
                          _WeeklyAchievementCard(),
                          SizedBox(height: 24.h),
                        ],
                        SizedBox(height: 24.h),
                        Center(
                          child: _buildProfileImage(state.user.profileImageUrl),
                        ),
                        // Objectifs tracking card for patients
                        if (state.user.role == UserRole.patient) ...[
                          SizedBox(height: 24.h),
                          InkWell(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.objectifs),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(14.w),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Icon(
                                        Icons.flag_rounded,
                                        color: AppColors.primaryPurple,
                                        size: 32.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Tracks',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.sp,
                                              color: AppColors.lightText,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Record your daily tracks',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.lightTextSecondary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
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
                                          color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10.r),
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
                                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
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
                        // Display patient information for family members
                        if (state.user.role == UserRole.familyMember && 
                            state.user.patientNom != null && 
                            state.user.patientPrenom != null) ...[
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
                                          color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10.r),
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
                                      color: AppColors.primaryPurple.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: AppColors.primaryPurple.withValues(alpha: 0.25),
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
                                      color: AppColors.lightTextSecondary,
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

String _getEnglishDescription(WeeklyAchievementModel achievement) {
  final apiDesc = achievement.badgeDescription;
  const frenchIndicators = ['Excellente', 'semaine', 'jours', 'humeur', 'consommés', 'enregistrer', 'Chaque'];
  final isFrench = frenchIndicators.any((w) => apiDesc.contains(w));
  return isFrench ? achievement.badge.description : apiDesc;
}

class _WeeklyAchievementCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeeklyAchievementModel>(
      future: ApiService().getWeeklyAchievement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final achievement = snapshot.data!;
        final badgeColor = _getBadgeColor(achievement.badge);

        return Card(
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
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Image.asset(
                        achievement.badge.assetPath,
                        fit: BoxFit.contain,
                        width: 40.w,
                        height: 40.w,
                        errorBuilder: (_, __, ___) => Text(
                          achievement.badge.emoji,
                          style: TextStyle(fontSize: 28.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Badge',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            achievement.badge.label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  _getEnglishDescription(achievement),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _StatChip(
                      label: 'Abstinent',
                      value: '${achievement.abstinentDays}d',
                      color: AppColors.success,
                    ),
                    SizedBox(width: 8.w),
                    _StatChip(
                      label: 'Consumed',
                      value: '${achievement.consumedDays}d',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBadgeColor(AchievementBadge badge) {
    switch (badge) {
      case AchievementBadge.champion:
        return const Color(0xFFFFB300); // Gold/amber
      case AchievementBadge.courageux:
        return AppColors.primaryPurple;
      case AchievementBadge.rebond:
        return AppColors.warning;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
