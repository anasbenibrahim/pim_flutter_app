import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Vertical thermometer slider with emoji faces — inspired by sleep quality screenshot
class Q4Sleep extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;
  const Q4Sleep({super.key, required this.value, required this.onChanged, required this.onNext});

  static const _levels = [
    _SleepLevel(5, 'Excellent', '7-9 hours', 'assets/images/mood emotions/happy.png', Color(0xFF46C67D)),
    _SleepLevel(4, 'Good', '6-7 hours', 'assets/images/mood emotions/smile character.png', Color(0xFF8BC34A)),
    _SleepLevel(3, 'Fair', '~5 hours', 'assets/images/mood emotions/normal.png', Color(0xFFF8C929)),
    _SleepLevel(2, 'Poor', '3-4 hours', 'assets/images/mood emotions/moody.png', Color(0xFFF9623E)),
    _SleepLevel(1, 'Worst', '<3 hours', 'assets/images/mood emotions/exhausted character.png', Color(0xFF9B59B6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text('How would you\nrate your\nsleep quality?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                  SizedBox(height: 6.h),
                  Text('Drag or tap to select 🌙', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                  SizedBox(height: 24.h),

                  // Thermometer-style vertical list
                  ..._levels.asMap().entries.map((e) {
                    final i = e.key;
                    final lev = e.value;
                    final selected = value == lev.score;
                    final above = value != null && lev.score <= value!;

                    return GestureDetector(
                      onTap: () => onChanged(lev.score),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            // Left labels
                            SizedBox(
                              width: 100.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: selected ? 16.sp : 14.sp,
                                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                      color: selected ? lev.color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                    child: Text(lev.label),
                                  ),
                                  Text(
                                    lev.hours,
                                    style: TextStyle(fontSize: 11.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                                  ),
                                ],
                              ),
                            ),

                            // Thermometer bar
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Track
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 48.h,
                                    decoration: BoxDecoration(
                                      color: above ? lev.color.withValues(alpha: 0.12) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.vertical(
                                        top: i == 0 ? Radius.circular(24.r) : Radius.zero,
                                        bottom: i == _levels.length - 1 ? Radius.circular(24.r) : Radius.zero,
                                      ),
                                    ),
                                  ),
                                  // Thumb
                                  if (selected)
                                    AnimatedScale(
                                      scale: 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.elasticOut,
                                      child: Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: lev.color,
                                          boxShadow: [BoxShadow(color: lev.color.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 2)],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // Right emoji
                            AnimatedScale(
                              scale: selected ? 1.3 : 0.9,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              child: AnimatedOpacity(
                                opacity: selected ? 1.0 : 0.4,
                                duration: const Duration(milliseconds: 200),
                                child: Image.asset(lev.asset, width: 44.w, height: 44.w),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _ContinueBtn(enabled: value != null, onTap: onNext),
        ],
      ),
    );
  }
}

class _SleepLevel {
  final int score;
  final String label, hours, asset;
  final Color color;
  const _SleepLevel(this.score, this.label, this.hours, this.asset, this.color);
}

class _ContinueBtn extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ContinueBtn({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: enabled ? const LinearGradient(colors: [AppColors.sapphire, Color(0xFF0A8F6F)]) : null,
          color: enabled ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: enabled ? [BoxShadow(color: AppColors.sapphire.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25))),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_rounded, size: 20.sp, color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }
}
