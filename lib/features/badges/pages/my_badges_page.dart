import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/achievement_badge.dart';
import '../../../core/models/weekly_achievement_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/custom_app_bar.dart';

DateTime _weekStart(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}

String _shortWeekLabel(DateTime weekStart) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  if (weekStart.month == weekEnd.month) {
    return '${weekStart.day}-${weekEnd.day} ${months[weekStart.month - 1]}';
  }
  return '${weekStart.day} ${months[weekStart.month - 1]} - ${weekEnd.day} ${months[weekEnd.month - 1]}';
}

class MyBadgesPage extends StatefulWidget {
  const MyBadgesPage({super.key});

  @override
  State<MyBadgesPage> createState() => _MyBadgesPageState();
}

class _MyBadgesPageState extends State<MyBadgesPage> {
  DateTime? _selectedWeekStart;
  WeeklyAchievementModel? _achievement;
  bool _loading = false;
  String? _error;

  List<DateTime> get _weeks {
    final now = DateTime.now();
    final todayWeekStart = _weekStart(now);
    return List.generate(20, (i) => todayWeekStart.subtract(Duration(days: 7 * i)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBadge(_weeks.first));
  }

  Future<void> _loadBadge(DateTime weekStart) async {
    setState(() {
      _selectedWeekStart = weekStart;
      _loading = true;
      _error = null;
    });
    try {
      final weekStr = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      final achievement = await ApiService().getWeeklyAchievement(weekStart: weekStr);
      if (mounted) {
        setState(() {
          _achievement = achievement;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Color _getBadgeColor(AchievementBadge badge) {
    switch (badge) {
      case AchievementBadge.champion:
        return const Color(0xFFFFB300);
      case AchievementBadge.courageux:
        return AppColors.primaryPurple;
      case AchievementBadge.rebond:
        return AppColors.warning;
    }
  }

  String _getEnglishDescription(WeeklyAchievementModel achievement) {
    final apiDesc = achievement.badgeDescription;
    const frenchIndicators = ['Excellente', 'semaine', 'jours', 'humeur', 'consommés', 'enregistrer', 'Chaque'];
    final isFrench = frenchIndicators.any((w) => apiDesc.contains(w));
    return isFrench ? achievement.badge.description : apiDesc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'My Badges', showBackButton: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
            child: Text(
              'Choose a week',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText,
              ),
            ),
          ),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: _weeks.length,
              itemBuilder: (context, index) {
                final weekStart = _weeks[index];
                final isSelected = _selectedWeekStart != null &&
                    _selectedWeekStart!.year == weekStart.year &&
                    _selectedWeekStart!.month == weekStart.month &&
                    _selectedWeekStart!.day == weekStart.day;
                return Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () => _loadBadge(weekStart),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryPurple : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(
                          _shortWeekLabel(weekStart),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.lightText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : _error != null
                    ? Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                        ),
                      )
                    : _achievement != null
                        ? SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: _SimpleBadgeCard(
                              achievement: _achievement!,
                              getBadgeColor: _getBadgeColor,
                              getDescription: _getEnglishDescription,
                            ),
                          )
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SimpleBadgeCard extends StatelessWidget {
  final WeeklyAchievementModel achievement;
  final Color Function(AchievementBadge) getBadgeColor;
  final String Function(WeeklyAchievementModel) getDescription;

  const _SimpleBadgeCard({
    required this.achievement,
    required this.getBadgeColor,
    required this.getDescription,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = getBadgeColor(achievement.badge);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    achievement.badge.assetPath,
                    fit: BoxFit.contain,
                    width: 48.w,
                    height: 48.w,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(achievement.badge.emoji, style: TextStyle(fontSize: 28.sp)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.badge.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: badgeColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Weekly badge',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            getDescription(achievement),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _StatChip(label: 'Abstinent', value: '${achievement.abstinentDays}d', color: AppColors.success),
              SizedBox(width: 12.w),
              _StatChip(label: 'Consumed', value: '${achievement.consumedDays}d', color: AppColors.error),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
