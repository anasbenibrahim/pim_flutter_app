import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class Q2Gender extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  const Q2Gender({super.key, required this.value, required this.onChanged, required this.onNext});

  @override
  State<Q2Gender> createState() => _Q2State();
}

class _Q2State extends State<Q2Gender> with SingleTickerProviderStateMixin {
  late AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _GenderOpt('Male', Icons.male_rounded, const Color(0xFF4A90D9), const Color(0xFFE3F2FD)),
      _GenderOpt('Female', Icons.female_rounded, const Color(0xFFE8729A), const Color(0xFFFCE4EC)),
      _GenderOpt('Other', Icons.diversity_1_rounded, const Color(0xFF9B59B6), const Color(0xFFF3E5F5)),
    ];

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How do you identify?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Text('We want to know\nyou better 💜', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/caring egg face with hands.png', height: 70.h, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  // Large pulsing bubbles
                  Center(
                    child: AnimatedBuilder(
                      animation: _breatheCtrl,
                      builder: (_, __) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: options.map((opt) {
                          final selected = widget.value == opt.label;
                          final breathe = 1.0 + (_breatheCtrl.value * 0.03);
                          return GestureDetector(
                            onTap: () => widget.onChanged(opt.label),
                            child: AnimatedScale(
                              scale: selected ? 1.15 : breathe,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 92.w,
                                    height: 92.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selected ? opt.color : (Theme.of(context).brightness == Brightness.dark ? opt.tint.withOpacity(0.15) : opt.tint),
                                      border: Border.all(
                                        color: selected ? opt.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.transparent),
                                        width: 3,
                                      ),
                                      boxShadow: selected
                                          ? [BoxShadow(color: opt.color.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 2)]
                                          : [],
                                    ),
                                    child: Icon(
                                      opt.icon,
                                      size: 38.sp,
                                      color: selected ? Colors.white : opt.color.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: selected ? 15.sp : 13.sp,
                                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                      color: selected ? opt.color : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                    child: Text(opt.label),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _ContinueBtn(enabled: widget.value != null, onTap: widget.onNext),
        ],
      ),
    );
  }
}

class _GenderOpt {
  final String label;
  final IconData icon;
  final Color color, tint;
  const _GenderOpt(this.label, this.icon, this.color, this.tint);
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
          color: enabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: enabled ? [BoxShadow(color: AppColors.sapphire.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.25))),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_rounded, size: 20.sp, color: enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.25)),
          ],
        ),
      ),
    );
  }
}
