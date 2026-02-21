import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

/// Mood picker — simple emoji text bubbles (no image loading = no crash)
class Q3Mood extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;
  const Q3Mood({super.key, required this.value, required this.onChanged, required this.onNext});

  static const _moods = [
    _Mood(1, '😢', 'Terrible', Color(0xFF9B59B6)),
    _Mood(2, '😔', 'Bad',      Color(0xFFF9623E)),
    _Mood(3, '😐', 'Okay',     Color(0xFFF8C929)),
    _Mood(4, '😊', 'Good',     Color(0xFF46C67D)),
    _Mood(5, '😄', 'Great',    Color(0xFF0D6078)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you\nfeeling?',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap the mood that fits right now',
            style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)),
          ),

          // ─── Bubbles ───
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16.w,
                runSpacing: 16.h,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: _moods.map((mood) {
                  final selected = value == mood.level;
                  return GestureDetector(
                    onTap: () => onChanged(mood.level),
                    child: SizedBox(
                      width: 100.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: 82.w,
                            height: 82.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? mood.color.withValues(alpha: 0.15)
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                              border: Border.all(
                                color: selected ? mood.color : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: selected
                                  ? [BoxShadow(color: mood.color.withValues(alpha: 0.3), blurRadius: 16)]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              mood.emoji,
                              style: TextStyle(fontSize: selected ? 38.sp : 32.sp),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected ? mood.color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Continue ───
          _ContinueBtn(enabled: value != null, onTap: onNext),
        ],
      ),
    );
  }
}

class _Mood {
  final int level;
  final String emoji, label;
  final Color color;
  const _Mood(this.level, this.emoji, this.label, this.color);
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
