import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/api_constants.dart';
import '../../home/pages/home_page.dart';
import '../../social/presentation/pages/social_feed_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final _pages = const [
    HomePage(key: ValueKey('home')),
    SocialFeedPage(key: ValueKey('social')),
    ProfilePage(key: ValueKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? profileImageUrl;
        if (state is AuthAuthenticated) {
          profileImageUrl = state.user.profileImageUrl;
        }

        return Scaffold(
          extendBody: true,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.fromLTRB(48.w, 0, 48.w, 28.h),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : theme.colorScheme.onSurface.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: isDark ? Border.all(color: Colors.white.withOpacity(0.05), width: 1) : null,
            ),
            child: Row(
              children: [
                _buildTab(context, index: 0, icon: Icons.home_rounded, label: 'Home'),
                _buildTab(context, index: 1, icon: Icons.forum_rounded, label: 'Social'),
                _buildTab(context, index: 2, icon: Icons.person_rounded, label: 'Profile', profileImageUrl: profileImageUrl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, {required int index, required IconData icon, required String label, String? profileImageUrl}) {
    final theme = Theme.of(context);
    final isActive = _currentIndex == index;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.3);

    // For profile tab with image
    Widget iconWidget;
    if (profileImageUrl != null && index == 2) {
      final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
      final url = profileImageUrl.startsWith('http') ? profileImageUrl : '$baseUrl$profileImageUrl';
      iconWidget = Container(
        width: 22.w, height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? activeColor : inactiveColor.withOpacity(0.15), width: 1.5),
        ),
        child: ClipOval(
          child: Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(icon, size: 14.sp, color: isActive ? activeColor : inactiveColor)),
        ),
      );
    } else {
      iconWidget = Icon(icon, size: 22.sp, color: isActive ? activeColor : inactiveColor);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              if (isActive) ...[
                SizedBox(width: 8.w),
                Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: activeColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
