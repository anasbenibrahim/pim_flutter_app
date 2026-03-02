import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class Q7Medications extends StatefulWidget {
  final bool? takingMeds;
  final String? medications;
  final ValueChanged<bool> onMedsChanged;
  final ValueChanged<String> onMedicationsChanged;
  final VoidCallback onNext;

  const Q7Medications({
    super.key,
    required this.takingMeds,
    required this.medications,
    required this.onMedsChanged,
    required this.onMedicationsChanged,
    required this.onNext,
  });

  @override
  State<Q7Medications> createState() => _Q7State();
}

class _Q7State extends State<Q7Medications> {
  late TextEditingController _medCtrl;

  @override
  void initState() {
    super.initState();
    _medCtrl = TextEditingController(text: widget.medications ?? '');
  }

  @override
  void dispose() {
    _medCtrl.dispose();
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
                            Text('Are you taking\nany medications?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Text('Prescribed or\nover-the-counter 💊', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/flowers.png', height: 70.h, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  // Large toggle cards
                  Row(
                    children: [
                      _buildToggle(context, true, '💊', 'Yes', AppColors.success),
                      SizedBox(width: 14.w),
                      _buildToggle(context, false, '✨', 'No', AppColors.brick),
                    ],
                  ),

                  // Animated text field slide-in
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: widget.takingMeds == true
                        ? Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: AnimatedOpacity(
                              opacity: widget.takingMeds == true ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04), blurRadius: 12)],
                                  border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
                                ),
                                child: TextField(
                                  controller: _medCtrl,
                                  onChanged: widget.onMedicationsChanged,
                                  style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'List your medications...',
                                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
                                    border: InputBorder.none,
                                    icon: Text('📋', style: TextStyle(fontSize: 20.sp)),
                                  ),
                                  maxLines: 3,
                                  minLines: 1,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          _ContinueBtn(enabled: widget.takingMeds != null, onTap: widget.onNext),
        ],
      ),
    );
  }

  Widget _buildToggle(BuildContext context, bool val, String emoji, String label, Color color) {
    final theme = Theme.of(context);
    final selected = widget.takingMeds == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onMedsChanged(val),
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(vertical: 28.h),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.12) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: selected ? color : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.transparent), width: 2.5),
              boxShadow: selected
                  ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4))]
                  : [BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.03), blurRadius: 8)],
            ),
            child: Column(
              children: [
                AnimatedScale(
                  scale: selected ? 1.4 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Text(emoji, style: TextStyle(fontSize: 34.sp)),
                 ),
                SizedBox(height: 10.h),
                Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: selected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
        ),
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
