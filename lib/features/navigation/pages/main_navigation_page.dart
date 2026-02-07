import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/pages/home_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  int? _previousIndex;

  List<Widget> get _pages => [
    const HomePage(key: ValueKey('home')),
    const ProfilePage(key: ValueKey('profile')),
  ];

  Widget _buildHomeTab(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        border: isActive
            ? Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home,
            size: 18.sp,
            color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.6),
          ),
          SizedBox(width: 5.w),
          Text(
            'Home',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(String? profileImageUrl, bool isActive) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        border: isActive
            ? Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Image
          if (profileImageUrl != null && profileImageUrl.isNotEmpty)
            ClipOval(
              child: Image.network(
                profileImageUrl.startsWith('http')
                    ? profileImageUrl
                    : '$baseUrl$profileImageUrl',
                width: 18.w,
                height: 18.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 18.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 10.sp,
                      color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 10.sp,
                color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.6),
              ),
            ),
          SizedBox(width: 5.w),
          // Profile Text
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? profileImageUrl;
        if (state is AuthAuthenticated) {
          profileImageUrl = state.user.profileImageUrl;
        }

        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Determine slide direction based on navigation direction
              final isForward = _currentIndex > (_previousIndex ?? 0);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(isForward ? 1.0 : -1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                child: GNav(
                  backgroundColor: Colors.transparent,
                  color: Colors.white.withValues(alpha: 0.6),
                  activeColor: AppColors.primaryPurple,
                  tabBackgroundColor: Colors.transparent,
                  gap: 8.w,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  tabs: [
                    GButton(
                      icon: Icons.home, // Required but will be hidden by leading
                      leading: _buildHomeTab(_currentIndex == 0),
                      text: '',
                      iconSize: 0, // Hide the icon since we're using leading
                    ),
                    GButton(
                      icon: Icons.person, // Required but will be hidden by leading
                      leading: _buildProfileTab(profileImageUrl, _currentIndex == 1),
                      text: '',
                      iconSize: 0, // Hide the icon since we're using leading
                    ),
                  ],
                  selectedIndex: _currentIndex,
                  onTabChange: (index) {
                    setState(() {
                      _previousIndex = _currentIndex;
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
