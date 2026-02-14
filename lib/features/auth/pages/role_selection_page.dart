import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      appBar: CustomAppBar(
        title: 'Choisir votre rôle',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.getPremiumText(context),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sélectionnez le profil qui vous correspond pour commencer.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.getPremiumTextSecondary(context),
              ),
            ),
            SizedBox(height: 32.h),
            _RoleCard(
              title: 'Patient',
              icon: Icons.person_rounded,
              description: 'Je souhaite suivre mon parcours de rétablissement.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.registerPatient),
            ),
            SizedBox(height: 16.h),
            _RoleCard(
              title: 'Volontaire',
              icon: Icons.volunteer_activism_rounded,
              description: 'Je souhaite aider et accompagner les autres.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.registerVolontaire),
            ),
            SizedBox(height: 16.h),
            _RoleCard(
              title: 'Membre de Famille',
              icon: Icons.family_restroom_rounded,
              description: 'Je souhaite soutenir un proche dans son parcours.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.registerFamily),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
                  ),
                  child: Icon(icon, size: 28.sp, color: AppColors.primaryPurple),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: AppColors.getPremiumText(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.getPremiumTextSecondary(context),
                          fontSize: 13.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
