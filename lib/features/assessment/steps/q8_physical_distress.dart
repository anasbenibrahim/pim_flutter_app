import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';

/// Floating symptom bubbles — organic scatter layout
class Q8PhysicalDistress extends StatefulWidget {
  final bool? value;
  final List<String> symptoms;
  final ValueChanged<bool> onChanged;
  final ValueChanged<List<String>> onSymptomsChanged;
  final VoidCallback onNext;

  const Q8PhysicalDistress({
    super.key,
    required this.value,
    required this.symptoms,
    required this.onChanged,
    required this.onSymptomsChanged,
    required this.onNext,
  });

  @override
  State<Q8PhysicalDistress> createState() => _Q8State();
}

class _Q8State extends State<Q8PhysicalDistress> with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  static const _allSymptoms = [
    _Symptom('😴', 'Fatigue', 75),
    _Symptom('🤕', 'Headaches', 68),
    _Symptom('💓', 'Heart racing', 72),
    _Symptom('😰', 'Sweating', 60),
    _Symptom('🤢', 'Nausea', 65),
    _Symptom('😖', 'Body aches', 70),
    _Symptom('🫁', 'Breathing', 62),
    _Symptom('🍽️', 'Appetite', 66),
    _Symptom('😵', 'Dizziness', 58),
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
                            Text('Any physical\nsymptoms?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Text('Your body tells\na story too 🫂', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/emotions.png', height: 70.h, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Yes/No toggle
                  Row(
                    children: [
                      _togglePill(context, true, 'Yes', AppColors.brick),
                      SizedBox(width: 10.w),
                      _togglePill(context, false, 'No, I\'m fine', AppColors.success),
                    ],
                  ),

                  // Floating symptom bubbles
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: widget.value == true
                        ? Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: AnimatedBuilder(
                              animation: _floatCtrl,
                              builder: (_, __) => Wrap(
                                spacing: 8.w,
                                runSpacing: 10.h,
                                alignment: WrapAlignment.center,
                                children: _allSymptoms.asMap().entries.map((e) {
                                  final i = e.key;
                                  final s = e.value;
                                  final key = '${s.emoji} ${s.label}';
                                  final selected = widget.symptoms.contains(key);

                                  final phase = i * 0.11;
                                  final t = ((_floatCtrl.value + phase) % 1.0);
                                  final dy = 3 * math.sin(t * math.pi * 2);

                                  return Transform.translate(
                                    offset: Offset(0, dy),
                                    child: GestureDetector(
                                      onTap: () {
                                        final copy = List<String>.from(widget.symptoms);
                                        selected ? copy.remove(key) : copy.add(key);
                                        widget.onSymptomsChanged(copy);
                                      },
                                      child: AnimatedScale(
                                        scale: selected ? 1.08 : 1.0,
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.elasticOut,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          width: s.size.w,
                                          height: s.size.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selected ? AppColors.brick.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                                            border: Border.all(color: selected ? AppColors.brick : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)), width: 2),
                                            boxShadow: selected
                                                ? [BoxShadow(color: AppColors.brick.withValues(alpha: 0.2), blurRadius: 12)]
                                                : [],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(s.emoji, style: TextStyle(fontSize: 20.sp)),
                                              SizedBox(height: 2.h),
                                              Text(
                                                s.label,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 9.sp,
                                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                                  color: selected ? AppColors.brick : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
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
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: 8.h),
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

  Widget _togglePill(BuildContext context, bool val, String label, Color color) {
    final theme = Theme.of(context);
    final selected = widget.value == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onChanged(val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: selected ? color : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.transparent), width: 2.5),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12)]
                : [],
          ),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: selected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.4))),
          ),
        ),
      ),
    );
  }
}

class _Symptom {
  final String emoji, label;
  final double size;
  const _Symptom(this.emoji, this.label, this.size);
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
