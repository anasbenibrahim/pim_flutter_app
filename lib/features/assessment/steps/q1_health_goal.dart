import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class Q1HealthGoal extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  const Q1HealthGoal({super.key, required this.value, required this.onChanged, required this.onNext});

  @override
  State<Q1HealthGoal> createState() => _Q1State();
}

class _Q1State extends State<Q1HealthGoal> with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late List<Animation<double>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  final _goals = const [
    _Goal('🎯', 'Complete sobriety', 'I want to stop completely', Color(0xFFE8F5E9)),
    _Goal('📉', 'Reduce usage', 'I want to cut back gradually', Color(0xFFFFF3E0)),
    _Goal('🧘', 'Build healthy habits', 'I want a healthier lifestyle', Color(0xFFE3F2FD)),
    _Goal('💪', 'Stay on track', "I'm sober and want support", Color(0xFFFCE4EC)),
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _slideAnims = List.generate(4, (i) {
      return Tween<double>(begin: 60, end: 0).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: Interval(i * 0.12, 0.5 + i * 0.12, curve: Curves.easeOutBack)),
      );
    });
    _fadeAnims = List.generate(4, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: Interval(i * 0.12, 0.4 + i * 0.12, curve: Curves.easeOut)),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What\'s your\nhealth goal?',
                              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'This helps us personalize\nyour journey ✨',
                              style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45)),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/images/design elements/Illustration.png',
                        height: 80.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Animated goal cards
                  ...List.generate(_goals.length, (i) {
                    final g = _goals[i];
                    final selected = widget.value == g.title;
                    return AnimatedBuilder(
                      animation: _entranceCtrl,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _slideAnims[i].value),
                        child: Opacity(
                          opacity: _fadeAnims[i].value,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: GestureDetector(
                              onTap: () => widget.onChanged(g.title),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutBack,
                                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                                decoration: BoxDecoration(
                                  color: selected ? (Theme.of(context).brightness == Brightness.dark ? g.tint.withOpacity(0.15) : g.tint) : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: selected ? AppColors.success : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.transparent),
                                    width: 2.5,
                                  ),
                                  boxShadow: selected
                                      ? [BoxShadow(color: AppColors.success.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))]
                                      : [BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  children: [
                                    AnimatedScale(
                                      scale: selected ? 1.3 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.elasticOut,
                                      child: Text(g.emoji, style: TextStyle(fontSize: 28.sp)),
                                    ),
                                    SizedBox(width: 14.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(g.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                                          SizedBox(height: 2.h),
                                          Text(g.subtitle, style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                                        ],
                                      ),
                                    ),
                                    AnimatedScale(
                                      scale: selected ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.elasticOut,
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                                        child: Icon(Icons.check_rounded, color: Colors.white, size: 16.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ─── Continue button ───
          SizedBox(height: 8.h),
          _AnimatedContinueBtn(enabled: widget.value != null, onTap: widget.onNext),
        ],
      ),
    );
  }
}

class _Goal {
  final String emoji, title, subtitle;
  final Color tint;
  const _Goal(this.emoji, this.title, this.subtitle, this.tint);
}

/// Shared premium continue button with scale + gradient animation
class _AnimatedContinueBtn extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _AnimatedContinueBtn({required this.enabled, required this.onTap});

  @override
  State<_AnimatedContinueBtn> createState() => _AnimatedContinueBtnState();
}

class _AnimatedContinueBtnState extends State<_AnimatedContinueBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.enabled) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimatedContinueBtn old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !old.enabled) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.enabled) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? LinearGradient(
                    colors: [AppColors.sapphire, Color.lerp(AppColors.sapphire, const Color(0xFF0A8F6F), _pulseCtrl.value)!],
                  )
                : null,
            color: widget.enabled ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: widget.enabled
                ? [BoxShadow(color: AppColors.sapphire.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20.sp,
                color: widget.enabled ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
