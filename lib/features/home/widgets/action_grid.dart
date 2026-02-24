import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';

// ═══════════════════════════════════════════
// Brand Palette
// ═══════════════════════════════════════════
const _sapphire  = Color(0xFF0D6078);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);
const _brick     = Color(0xFFF9623E);
const _indigo    = Color(0xFF022F40);
const _linen     = Color(0xFFF2EBE1);

/// Quick Actions grid — 4 square buttons: Journal, Mood-in, SOS, Support Circle.
class ActionGrid extends StatelessWidget {
  final Function(String?)? onGameFinished;

  const ActionGrid({super.key, this.onGameFinished});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _linen),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _ActionButton(icon: Icons.edit_note_rounded, label: 'Journal',  iconBg: _emerald,   onTap: () {}),
            SizedBox(width: 10.w),
            _ActionButton(
              icon: Icons.mood_rounded,      
              label: 'Mood-in',  
              iconBg: _sunflower,  
              onTap: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.gameSelection);
                if (result != null && result is String) {
                  onGameFinished?.call(result);
                }
              },
            ),
            SizedBox(width: 10.w),
            _ActionButton(icon: Icons.sos_rounded,       label: 'SOS',      iconBg: _brick,      onTap: () { HapticFeedback.heavyImpact(); }),
            SizedBox(width: 10.w),
            _ActionButton(icon: Icons.group_rounded,     label: 'Support\nCircle', iconBg: _sapphire, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

/// A single action card with icon circle + label.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: _indigo.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: iconBg.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _linen.withOpacity(0.9), height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
