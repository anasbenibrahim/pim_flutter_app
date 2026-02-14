import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/theme/app_colors.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 1.sh,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // HopeUp Integrated Branding Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [AppColors.primaryPurple, Color(0xFF00F2FE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      'HopeUp',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const HopeUpLogo(size: 180),
                ],
              ),
              const Spacer(flex: 1),
              Text(
                'Bienvenue sur HopeUp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28.sp,
                  color: AppColors.getPremiumText(context),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Votre écosystème intelligent de protection et d\'accompagnement vers une sobriété durable.',
                style: TextStyle(
                  color: AppColors.getPremiumTextSecondary(context),
                  fontSize: 15.sp,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              
              GlassCard(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Se Connecter',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.roleSelection),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.getPremiumText(context),
                        side: BorderSide(color: AppColors.getPremiumTextSecondary(context).withOpacity(0.2)),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text(
                        'Créer un Compte',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
