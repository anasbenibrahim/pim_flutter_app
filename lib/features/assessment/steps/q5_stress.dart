import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Giant animated number with color-coded background shift — inspired by stress level screenshot
class Q5Stress extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;
  const Q5Stress({super.key, required this.value, required this.onChanged, required this.onNext});

  static const _colors = [
    Color(0xFF46C67D), // 1 - green
    Color(0xFF8BC34A), // 2 - lime
    Color(0xFFF8C929), // 3 - yellow
    Color(0xFFFF9800), // 4 - orange
    Color(0xFFF9623E), // 5 - red
  ];

  static const _labels = [
    'Very relaxed',
    'Mostly calm',
    'Somewhat stressed',
    'Quite stressed',
    'Extremely stressed',
  ];

  @override
  Widget build(BuildContext context) {
    final color = value != null ? _colors[value! - 1] : Colors.indigo.withOpacity(0.2);

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text('How would you\nrate your\nstress level?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                SizedBox(height: 6.h),
                Text('Be honest with yourself 🫂', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),

                const Spacer(),

                // Giant number display
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, anim) {
                      return ScaleTransition(
                        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: Text(
                      value != null ? '$value' : '?',
                      key: ValueKey(value),
                      style: TextStyle(
                        fontSize: 110.sp,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Label
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      value != null ? _labels[value! - 1] : 'Tap a number below',
                      key: ValueKey(value),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: value != null ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Number selector row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (i) {
                    final n = i + 1;
                    final selected = value == n;
                    final c = _colors[i];
                    return GestureDetector(
                      onTap: () => onChanged(n),
                      child: AnimatedScale(
                        scale: selected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 52.w,
                          height: 52.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? c : (Theme.of(context).brightness == Brightness.dark ? c.withOpacity(0.15) : c.withOpacity(0.1)),
                            boxShadow: selected
                                ? [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2)]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                color: selected ? Colors.white : c,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
          _ContinueBtn(enabled: value != null, onTap: onNext),
        ],
      ),
    );
  }
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
