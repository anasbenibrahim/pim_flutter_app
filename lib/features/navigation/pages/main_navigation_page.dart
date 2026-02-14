import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../core/widgets/premium_widgets.dart';
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.home_rounded : Icons.home_outlined,
            size: 24.sp,
            color: isActive ? AppColors.primaryPurple : AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
          ),
          if (isActive) ...[
            SizedBox(width: 8.w),
            Text(
              'Home',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab(String? profileImageUrl, bool isActive) {
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isActive 
                  ? Border.all(color: AppColors.primaryPurple, width: 1.5)
                  : Border.all(color: AppColors.getPremiumTextSecondary(context).withOpacity(0.3), width: 1),
            ),
            child: ClipOval(
              child: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? Image.network(
                      profileImageUrl.startsWith('http')
                          ? profileImageUrl
                          : '$baseUrl$profileImageUrl',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person_rounded,
                        size: 14.sp,
                        color: isActive ? AppColors.primaryPurple : AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 14.sp,
                      color: isActive ? AppColors.primaryPurple : AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                    ),
            ),
          ),
          if (isActive) ...[
            SizedBox(width: 8.w),
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
                letterSpacing: -0.5,
              ),
            ),
          ],
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
          extendBody: true, // Crucial for letting content flow behind the floating bar
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isForward = _currentIndex > (_previousIndex ?? 0);
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(isForward ? 0.05 : -0.05, 0.0), // Subtle slide
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _pages[_currentIndex],
              ),
              
              // Floating Premium Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FloatingGlassNavBar(
                  child: GNav(
                    backgroundColor: Colors.transparent,
                    color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5),
                    activeColor: AppColors.primaryPurple,
                    tabBackgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                    gap: 8.w,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutExpo,
                    tabs: [
                      GButton(
                        icon: Icons.home_rounded,
                        leading: _buildHomeTab(_currentIndex == 0),
                        text: '',
                        iconSize: 0,
                      ),
                      GButton(
                        icon: Icons.person_rounded,
                        leading: _buildProfileTab(profileImageUrl, _currentIndex == 1),
                        text: '',
                        iconSize: 0,
                      ),
                    ],
                    selectedIndex: _currentIndex,
                    onTabChange: (index) {
                      if (_currentIndex != index) {
                        setState(() {
                          _previousIndex = _currentIndex;
                          _currentIndex = index;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
