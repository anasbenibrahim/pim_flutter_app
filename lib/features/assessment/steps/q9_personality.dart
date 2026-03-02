import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';

/// Floating personality word bubbles — organic scatter
class Q9Personality extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onNext;
  const Q9Personality({super.key, required this.selected, required this.onChanged, required this.onNext});

  @override
  State<Q9Personality> createState() => _Q9State();
}

class _Q9State extends State<Q9Personality> with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  static const _traits = [
    _Trait('🌟', 'Optimistic', 78, Color(0xFFF8C929)),
    _Trait('🤝', 'Empathetic', 72, Color(0xFF46C67D)),
    _Trait('🧠', 'Analytical', 70, Color(0xFF4A90D9)),
    _Trait('🎨', 'Creative', 75, Color(0xFFE8729A)),
    _Trait('💪', 'Determined', 68, Color(0xFFF9623E)),
    _Trait('😊', 'Social', 65, Color(0xFF0D6078)),
    _Trait('🦉', 'Introverted', 74, Color(0xFF9B59B6)),
    _Trait('⚡', 'Impulsive', 62, Color(0xFFFF9800)),
    _Trait('😟', 'Anxious', 66, Color(0xFFF44336)),
    _Trait('🔥', 'Passionate', 70, Color(0xFFF9623E)),
    _Trait('🕊️', 'Calm', 64, Color(0xFF0A8F6F)),
    _Trait('🎯', 'Focused', 68, Color(0xFF0D6078)),
    _Trait('🌊', 'Sensitive', 72, Color(0xFF4A90D9)),
    _Trait('🤔', 'Overthinking', 76, Color(0xFF9B59B6)),
    _Trait('❤️', 'Caring', 66, Color(0xFFE8729A)),
  ];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
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
                             Text('How would you\ndescribe yourself?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                 Text('Pick as many as you like! ', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                                if (widget.selected.isNotEmpty)
                                   Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(color: AppColors.sunflower.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10.r)),
                                    child: Text('${widget.selected.length}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.sunflower)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/love unity.png', height: 65.h, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Floating bubbles
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, __) => Wrap(
                      spacing: 6.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: _traits.asMap().entries.map((e) {
                        final i = e.key;
                        final t = e.value;
                        final key = '${t.emoji} ${t.label}';
                        final isSel = widget.selected.contains(key);

                        final phase = i * 0.07;
                        final ft = ((_floatCtrl.value + phase) % 1.0);
                        final dy = 3 * math.sin(ft * math.pi * 2);

                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: GestureDetector(
                            onTap: () {
                              final copy = List<String>.from(widget.selected);
                              isSel ? copy.remove(key) : copy.add(key);
                              widget.onChanged(copy);
                            },
                            child: AnimatedScale(
                              scale: isSel ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.elasticOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: t.size.w,
                                height: t.size.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSel ? t.color.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                                    border: Border.all(color: isSel ? t.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)), width: 2),
                                    boxShadow: isSel
                                        ? [BoxShadow(color: t.color.withValues(alpha: 0.2), blurRadius: 12)]
                                        : [],
                                  ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(t.emoji, style: TextStyle(fontSize: 18.sp)),
                                    SizedBox(height: 2.h),
                                    Text(
                                      t.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                          color: isSel ? t.color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                                        ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _ContinueBtn(enabled: widget.selected.isNotEmpty, onTap: widget.onNext),
        ],
      ),
    );
  }
}

class _Trait {
  final String emoji, label;
  final double size;
  final Color color;
  const _Trait(this.emoji, this.label, this.size, this.color);
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
          boxShadow: enabled ? [BoxShadow(color: AppColors.sapphire.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))] : null,
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
