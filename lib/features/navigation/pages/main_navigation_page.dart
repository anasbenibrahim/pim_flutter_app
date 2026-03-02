import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/user_role.dart';
import '../../home/pages/home_page.dart';
import '../../social/presentation/pages/social_feed_page.dart';
import '../../goals/pages/goals_hub_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

/// Allows child routes to request switching to the Goals tab (e.g. after validating a goal).
class GoalsTabScope extends InheritedWidget {
  final VoidCallback switchToGoalsTab;

  const GoalsTabScope({
    super.key,
    required this.switchToGoalsTab,
    required super.child,
  });

  static GoalsTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GoalsTabScope>();
  }

  @override
  bool updateShouldNotify(GoalsTabScope old) => switchToGoalsTab != old.switchToGoalsTab;
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  static const int _goalsTabIndex = 2;

  void _switchToGoalsTab() {
    if (_currentIndex != _goalsTabIndex) {
      setState(() => _currentIndex = _goalsTabIndex);
    }
  }

  List<Widget> _buildPages(UserRole? role) {
    final base = [
      const HomePage(key: ValueKey('home')),
      const SocialFeedPage(key: ValueKey('social')),
      const ProfilePage(key: ValueKey('profile')),
    ];
    // Goals tab only for patients (addiction reduction flow)
    if (role == UserRole.patient) {
      return [
        const HomePage(key: ValueKey('home')),
        const SocialFeedPage(key: ValueKey('social')),
        const GoalsHubPage(key: ValueKey('goals')),
        const ProfilePage(key: ValueKey('profile')),
      ];
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? profileImageUrl;
        UserRole? userRole;
        if (state is AuthAuthenticated) {
          profileImageUrl = state.user.profileImageUrl;
          userRole = state.user.role;
        }
        final pages = _buildPages(userRole);
        final maxIndex = pages.length - 1;
        final safeIndex = _currentIndex > maxIndex ? maxIndex : _currentIndex;

        return GoalsTabScope(
          switchToGoalsTab: _switchToGoalsTab,
          child: Scaffold(
            extendBody: true,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: pages[safeIndex],
            ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
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
                _buildTab(context, index: 1, icon: Icons.article_rounded, label: 'Social'),
                if (userRole == UserRole.patient)
                  _buildTab(context, index: 2, icon: Icons.emoji_events_rounded, label: 'Goals'),
                _buildTab(
                  context,
                  index: userRole == UserRole.patient ? 3 : 2,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  profileImageUrl: profileImageUrl,
                ),
              ],
            ),
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

    // For profile tab with image (profile index varies: 2 for non-patient, 3 for patient)
    Widget iconWidget;
    if (profileImageUrl != null) {
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                if (isActive) ...[
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: activeColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
