import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/models/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Tableau de Bord',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, size: 24.sp, color: AppColors.getPremiumTextSecondary(context)),
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
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state.user.prenom, state.user.nom, state.user.profileImageUrl),
                  SizedBox(height: 32.h),
                  
                  const PremiumSectionTitle(title: 'Votre Profil', icon: Icons.badge_outlined),
                  _buildRoleCard(state.user.role),
                  
                  if (state.user.role == UserRole.patient) ...[
                    const PremiumSectionTitle(title: 'Suivi de Sobriété', icon: Icons.auto_graph_rounded),
                    _buildSobrietyCard(state.user.addiction, state.user.sobrietyDate),
                    
                    const PremiumSectionTitle(title: 'Parrainage', icon: Icons.share_rounded),
                    _buildReferralCard(state.user.referralCode),
                  ],
                  
                  if (state.user.role == UserRole.familyMember && 
                      state.user.patientNom != null) ...[
                    const PremiumSectionTitle(title: 'Patient Suivi', icon: Icons.favorite_outline_rounded),
                    _buildRelatedPatientCard(state.user.patientPrenom!, state.user.patientNom!),
                  ],
                  
                  SizedBox(height: 100.h), // Space for bottom nav or scrolling
                ],
              ),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.primaryPurple,
                size: 50.sp,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(String prenom, String nom, String? profileImageUrl) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue,',
                style: TextStyle(fontSize: 18.sp, color: AppColors.getPremiumTextSecondary(context), fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 4.h),
              Text(
                '$prenom $nom',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPremiumText(context),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        _buildProfileAvatar(profileImageUrl),
      ],
    );
  }

  Widget _buildProfileAvatar(String? profileImageUrl) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = profileImageUrl != null 
        ? (profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl')
        : null;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 35.r,
        backgroundColor: AppColors.getGlassColor(context),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null 
            ? Icon(Icons.person_rounded, size: 35.sp, color: AppColors.primaryPurple)
            : null,
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(_getRoleIcon(role), color: AppColors.primaryPurple, size: 32.sp),
          ),
          SizedBox(width: 20.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rôle Actuel',
                style: TextStyle(fontSize: 14.sp, color: AppColors.getPremiumTextSecondary(context)),
              ),
              SizedBox(height: 4.h),
              Text(
                role.displayName,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSobrietyCard(String? addiction, DateTime? sobrietyDate) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Substance', style: TextStyle(fontSize: 14.sp, color: AppColors.getPremiumTextSecondary(context))),
                    SizedBox(height: 4.h),
                    Text(
                      addiction ?? 'Non spécifiée',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
                    ),
                  ],
                ),
              ),
              if (sobrietyDate != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'En progrès',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                ),
            ],
          ),
          if (sobrietyDate != null) ...[
            SizedBox(height: 24.h),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Libre depuis le', style: TextStyle(fontSize: 14.sp, color: AppColors.getPremiumTextSecondary(context))),
                Text(
                  DateFormat('dd MMMM yyyy', 'fr_FR').format(sobrietyDate),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReferralCard(String? code) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Partagez votre code avec vos proches pour qu\'ils puissent vous soutenir.',
            style: TextStyle(fontSize: 14.sp, color: AppColors.getPremiumTextSecondary(context), height: 1.4),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.getGlassColor(context),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    code ?? 'Chargement...',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                if (code != null)
                  IconButton(
                    icon: Icon(Icons.copy_rounded, color: AppColors.primaryPurple, size: 24.sp),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Get.snackbar(
                        'Succès',
                        'Code copié dans le presse-papier',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColors.primaryPurple,
                        colorText: Colors.white,
                        margin: EdgeInsets.all(16),
                        borderRadius: 12.r,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedPatientCard(String prenom, String nom) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline_rounded, color: Colors.blueAccent, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vous suivez', style: TextStyle(fontSize: 14.sp, color: AppColors.getPremiumTextSecondary(context))),
              SizedBox(height: 4.h),
              Text(
                '$prenom $nom',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person_rounded;
      case UserRole.volontaire:
        return Icons.volunteer_activism_rounded;
      case UserRole.familyMember:
        return Icons.family_restroom_rounded;
    }
  }
}
