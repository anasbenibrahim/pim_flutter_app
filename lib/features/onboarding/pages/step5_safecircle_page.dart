import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';

class SafeCirclePage extends StatelessWidget {
  final VoidCallback onFinish;

  const SafeCirclePage({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ton Soutien",
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.getPremiumText(context)),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Invite ton cercle de confiance pour t'épauler.",
                  style: TextStyle(color: AppColors.getPremiumTextSecondary(context), fontSize: 14.sp),
                ),
                SizedBox(height: 32.h),

                GlassCard(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryPurple.withOpacity(0.1),
                        ),
                        child: Icon(Icons.people_alt_rounded, size: 48.sp, color: AppColors.primaryPurple),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        "Ton Code de Parrainage",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.getPremiumText(context)),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Partage ce code avec tes proches pour qu'ils rejoignent ton SafeCircle.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.sp, color: AppColors.getPremiumTextSecondary(context).withOpacity(0.7)),
                      ),
                      SizedBox(height: 24.h),
                      
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          String code = "Chargement...";
                          if (authState is AuthAuthenticated) {
                            code = authState.user.referralCode ?? "PAS DE CODE";
                          } else if (authState is AuthOnboardingRequired) {
                            code = authState.user.referralCode ?? "GENERATION...";
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: AppColors.getGlassColor(context).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.getGlassBorder(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 24.sp, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.primaryPurple,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                IconButton(
                                  icon: Icon(Icons.copy_rounded, size: 20.sp, color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5)),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Code copié !"))
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),
                GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.security_rounded, color: AppColors.success, size: 24.sp),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          "Tes données sont sécurisées et partagées uniquement avec ton cercle.",
                          style: TextStyle(fontSize: 13.sp, color: AppColors.getPremiumTextSecondary(context)),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 64.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status == OnboardingStatus.loading ? null : onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      disabledBackgroundColor: AppColors.primaryPurple.withOpacity(0.5),
                    ),
                    child: state.status == OnboardingStatus.loading
                        ? LoadingAnimationWidget.threeRotatingDots(
                            color: Colors.white,
                            size: 24.sp,
                          )
                        : Text(
                            "Terminer l'installation",
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
