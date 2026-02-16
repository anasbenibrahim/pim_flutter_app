import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_role.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/pages/home_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../objectifs/pages/objectifs_list_page.dart';
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

  List<Widget> _getPages(bool isPatient) {
    if (isPatient) {
      return [
        const HomePage(key: ValueKey('home')),
        const ObjectifsListPage(key: ValueKey('objectifs')),
        const ProfilePage(key: ValueKey('profile')),
      ];
    }
    return [
      const HomePage(key: ValueKey('home')),
      const ProfilePage(key: ValueKey('profile')),
    ];
  }

  Widget _buildHomeTab(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.12) : Colors.transparent,
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
          ClipOval(
            child: Image.asset(
              'assets/images/home.png',
              width: 18.w,
              height: 18.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.home,
                size: 18.sp,
                color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'Home',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectifsTab(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.12) : Colors.transparent,
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
          ClipOval(
            child: Image.asset(
              'assets/images/track.png',
              width: 18.w,
              height: 18.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.flag,
                size: 18.sp,
                color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'Tracks',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
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
        color: isActive ? AppColors.primaryPurple.withValues(alpha: 0.12) : Colors.transparent,
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
                      color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
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
                color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
              ),
            ),
          SizedBox(width: 5.w),
          // Profile Text
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.primaryPurple : AppColors.lightTextSecondary,
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
        final isPatient = state is AuthAuthenticated &&
            state.user.role == UserRole.patient;
        if (state is AuthAuthenticated) {
          profileImageUrl = state.user.profileImageUrl;
        }

        final pages = _getPages(isPatient);
        final profileIndex = isPatient ? 2 : 1;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: AppColors.lightBackground,
            body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
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
            child: _currentIndex < pages.length
                ? pages[_currentIndex]
                : pages[0],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                child: GNav(
                  backgroundColor: Colors.transparent,
                  color: AppColors.lightTextSecondary,
                  activeColor: AppColors.primaryPurple,
                  tabBackgroundColor: Colors.transparent,
                  gap: 8.w,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  tabs: [
                    GButton(
                      icon: Icons.home,
                      leading: _buildHomeTab(_currentIndex == 0),
                      text: '',
                      iconSize: 0,
                    ),
                    if (isPatient)
                      GButton(
                        icon: Icons.flag,
                        leading: _buildObjectifsTab(_currentIndex == 1),
                        text: '',
                        iconSize: 0,
                      ),
                    GButton(
                      icon: Icons.person,
                      leading: _buildProfileTab(
                        profileImageUrl,
                        _currentIndex == profileIndex,
                      ),
                      text: '',
                      iconSize: 0,
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
        ),
      );
    },
    );
  }
}
