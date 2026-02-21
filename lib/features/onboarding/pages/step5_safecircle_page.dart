import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);

class SafeCirclePage extends StatelessWidget {
  final VoidCallback onFinish;

  const SafeCirclePage({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _linen,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ton Soutien", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: _indigo, letterSpacing: -0.5)),
                SizedBox(height: 6.h),
                Text("Invite ton cercle de confiance pour t'épauler.", style: TextStyle(color: _indigo.withOpacity(0.5), fontSize: 14.sp)),
                SizedBox(height: 32.h),

                // Referral Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _sapphire.withOpacity(0.08)),
                        child: Icon(Icons.people_alt_rounded, size: 40.sp, color: _sapphire),
                      ),
                      SizedBox(height: 20.h),
                      Text("Ton Code de Parrainage", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _indigo)),
                      SizedBox(height: 8.h),
                      Text(
                        "Partage ce code avec tes proches pour qu'ils rejoignent ton SafeCircle.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.sp, color: _indigo.withOpacity(0.45), height: 1.5),
                      ),
                      SizedBox(height: 20.h),

                      // Code Display
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          String code = "Chargement...";
                          if (authState is AuthAuthenticated) {
                            code = authState.user.referralCode ?? "PAS DE CODE";
                          } else if (authState is AuthOnboardingRequired) {
                            code = authState.user.referralCode ?? "GENERATION...";
                          }
                          return GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Code copié !"),
                                  backgroundColor: _emerald,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                color: _sapphire.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(color: _sapphire.withOpacity(0.12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      code,
                                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _sapphire, letterSpacing: 1.5),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Icon(Icons.copy_rounded, size: 18.sp, color: _indigo.withOpacity(0.3)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Security info
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: _indigo.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(color: _emerald.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(Icons.shield_rounded, color: _emerald, size: 20.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          "Tes données sont sécurisées et partagées uniquement avec ton cercle.",
                          style: TextStyle(fontSize: 13.sp, color: _indigo.withOpacity(0.55), height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // Finish Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.status == OnboardingStatus.loading ? null : onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sapphire, foregroundColor: Colors.white,
                      disabledBackgroundColor: _sapphire.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)), elevation: 0,
                    ),
                    child: state.status == OnboardingStatus.loading
                        ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text("Terminer l'installation", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8.w), Icon(Icons.check_circle_outline_rounded, size: 18.sp),
                          ]),
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
