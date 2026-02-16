import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/routes/app_routes.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(
            title: 'Select Your Role',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  _buildRoleCard(
                    context,
                    title: 'Patient',
                    icon: Icons.person,
                    description: 'Register as a patient',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.registerPatient);
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildRoleCard(
                    context,
                    title: 'Volontaire',
                    icon: Icons.volunteer_activism,
                    description: 'Register as a volunteer',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.registerVolontaire);
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildRoleCard(
                    context,
                    title: 'Family Member',
                    icon: Icons.family_restroom,
                    description: 'Register as a family member',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.registerFamily);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
  }
  
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: const Color(0xFF593A84).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: const Color(0xFF593A84),
              ),
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
                      color: const Color(0xFF333333),
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: const Color(0xFF666666),
                      fontSize: 14.sp,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Chevron Icon
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: const Color(0xFF593A84),
            ),
          ],
        ),
      ),
    );
  }
}
