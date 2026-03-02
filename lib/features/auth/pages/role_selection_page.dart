import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';

// ─── HopeUp Palette ───
const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _linen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _indigo, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qui êtes-vous ?',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: _indigo,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sélectionnez le profil qui vous correspond pour commencer.',
              style: TextStyle(
                fontSize: 14.sp,
                color: _indigo.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            SizedBox(height: 36.h),

            _RoleCard(
              title: 'Patient',
              icon: Icons.person_rounded,
              description: 'Je souhaite suivre mon parcours de rétablissement.',
              accentColor: _sapphire,
              onTap: () => Navigator.pushNamed(context, AppRoutes.registerPatient),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _indigo.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: _indigo.withOpacity(0.04),
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
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
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
                      color: _indigo,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: _indigo.withOpacity(0.5),
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
              color: _indigo.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
