import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import '../../../core/theme/app_colors.dart';

/// Floating mental-health concern bubbles + celebratory finish
class Q10MentalHealth extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onSubmit;
  final bool submitting;

  const Q10MentalHealth({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  State<Q10MentalHealth> createState() => _Q10State();
}

class _Q10State extends State<Q10MentalHealth> with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;

  static const _concerns = [
    _Concern('😰', 'Anxiety', 72, Color(0xFF9B59B6)),
    _Concern('😞', 'Depression', 70, Color(0xFF4A90D9)),
    _Concern('😤', 'Anger', 64, Color(0xFFF9623E)),
    _Concern('🧩', 'ADHD', 66, Color(0xFFFF9800)),
    _Concern('🌀', 'OCD', 62, Color(0xFF0D6078)),
    _Concern('😱', 'Panic', 68, Color(0xFFF44336)),
    _Concern('🫣', 'Social anxiety', 78, Color(0xFFE8729A)),
    _Concern('😔', 'Low esteem', 74, Color(0xFF795548)),
    _Concern('🍔', 'Eating', 60, Color(0xFF8BC34A)),
    _Concern('🛌', 'Insomnia', 66, Color(0xFF3F51B5)),
    _Concern('🧠', 'Memory', 64, Color(0xFF0A8F6F)),
    _Concern('💭', 'Intrusive thoughts', 80, Color(0xFF9B59B6)),
    _Concern('🚫', 'None', 62, Color(0xFF46C67D)),
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
                            Text('Any mental health\nconcerns?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Text('Almost there! 🎉 ', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                                if (widget.selected.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(color: AppColors.sapphire.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
                                    child: Text('${widget.selected.length}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.sapphire)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/faces vertical 2.png', height: 65.h, fit: BoxFit.contain),
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
                      children: _concerns.asMap().entries.map((e) {
                        final i = e.key;
                        final c = e.value;
                        final key = '${c.emoji} ${c.label}';
                        final isSel = widget.selected.contains(key);
                        final isNone = c.label == 'None';

                        final phase = i * 0.08;
                        final ft = ((_floatCtrl.value + phase) % 1.0);
                        final dy = 3 * math.sin(ft * math.pi * 2);

                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: GestureDetector(
                            onTap: () {
                              final copy = List<String>.from(widget.selected);
                              if (isNone) {
                                copy.clear();
                                if (!isSel) copy.add(key);
                              } else {
                                copy.remove('🚫 None');
                                isSel ? copy.remove(key) : copy.add(key);
                              }
                              widget.onChanged(copy);
                            },
                            child: AnimatedScale(
                              scale: isSel ? 1.08 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.elasticOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: c.size.w,
                                height: c.size.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSel ? c.color.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
                                  border: Border.all(color: isSel ? c.color : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)), width: 2),
                                  boxShadow: isSel
                                      ? [BoxShadow(color: c.color.withValues(alpha: 0.2), blurRadius: 12)]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(c.emoji, style: TextStyle(fontSize: 18.sp)),
                                    SizedBox(height: 2.h),
                                    Text(
                                      c.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                        color: isSel ? c.color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
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

          // Submit button
          GestureDetector(
            onTap: (widget.selected.isNotEmpty && !widget.submitting) ? widget.onSubmit : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: widget.selected.isNotEmpty
                    ? const LinearGradient(colors: [AppColors.sapphire, AppColors.success])
                    : null,
                color: widget.selected.isEmpty ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06) : null,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: widget.selected.isNotEmpty
                    ? [BoxShadow(color: AppColors.sapphire.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))]
                    : null,
              ),
              child: widget.submitting
                  ? Center(child: SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Finish Assessment 🎉',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: widget.selected.isNotEmpty ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Concern {
  final String emoji, label;
  final double size;
  final Color color;
  const _Concern(this.emoji, this.label, this.size, this.color);
}
