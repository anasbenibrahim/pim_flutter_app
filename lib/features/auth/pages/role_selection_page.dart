import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';

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

const _sapphire  = Color(0xFF0D6078);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _forestGradient),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qui êtes-vous ?',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sélectionnez le profil qui vous correspond pour commencer.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 36.h),

                    _RoleCard(
                      title: 'Patient',
                      icon: Icons.person_rounded,
                      description: 'Je souhaite suivre mon parcours de rétablissement.',
                      accentColor: Colors.white,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.onboarding),
                    ),
                    SizedBox(height: 16.h),
                    _RoleCard(
                      title: 'Volontaire',
                      icon: Icons.volunteer_activism_rounded,
                      description: 'Je souhaite aider et accompagner les autres.',
                      accentColor: _emerald,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.registerVolontaire),
                    ),
                    SizedBox(height: 16.h),
                    _RoleCard(
                      title: 'Membre de Famille',
                      icon: Icons.family_restroom_rounded,
                      description: 'Je souhaite soutenir un proche dans son parcours.',
                      accentColor: _sunflower,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.registerFamily),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
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
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: _indigo.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(icon, size: 26.sp, color: accentColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
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
              size: 14.sp,
              color: Colors.white.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
