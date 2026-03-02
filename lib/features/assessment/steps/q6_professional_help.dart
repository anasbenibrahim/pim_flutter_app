import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';

class Q6ProfessionalHelp extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onNext;
  const Q6ProfessionalHelp({super.key, required this.value, required this.onChanged, required this.onNext});

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
                            Text('Have you sought\nprofessional help?', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, height: 1.15, letterSpacing: -0.5)),
                            SizedBox(height: 6.h),
                            Text("No right or wrong\nanswer here 🤝", style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                          ],
                        ),
                      ),
                      Image.asset('assets/images/design elements/love unity.png', height: 75.h, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Two large illustrated cards
                  Row(
                    children: [
                      _buildCard(
                        context,
                        true,
                        'assets/images/design elements/caring hearts.png',
                        'Yes, I have',
                        AppColors.success,
                      ),
                      SizedBox(width: 14.w),
                      _buildCard(
                        context,
                        false,
                        'assets/images/design elements/hand giving flowers.png',
                        'Not yet',
                        AppColors.brick,
                      ),
                    ],
                  ),
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

  Widget _buildCard(BuildContext context, bool val, String asset, String label, Color color) {
    final theme = Theme.of(context);
    final selected = value == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(val),
        child: AnimatedScale(
          scale: selected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.12) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: selected ? color : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.transparent), width: 2.5),
              boxShadow: selected
                  ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4))]
                  : [BoxShadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.03), blurRadius: 8)],
            ),
            child: Column(
              children: [
                Image.asset(asset, height: 70.h, fit: BoxFit.contain),
                SizedBox(height: 14.h),
                Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: selected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                SizedBox(height: 8.h),
                AnimatedScale(
                  scale: selected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 16.sp),
                  ),
                ),
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
