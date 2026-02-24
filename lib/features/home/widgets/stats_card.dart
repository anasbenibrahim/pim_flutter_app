import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════
// Brand Palette
// ═══════════════════════════════════════════
const _sapphire  = Color(0xFF0D6078);
const _sunflower = Color(0xFFF8C929);
const _emerald   = Color(0xFF46C67D);
const _indigo    = Color(0xFF022F40);
const _linen     = Color(0xFFF2EBE1);

/// "Your Journey" stats card — shows streak count, star rating, date, and Hopi avatar.
class StatsCard extends StatelessWidget {
  final int streakDays;

  const StatsCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _sapphire,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: _indigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // ─── Left: Text Content ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: _sunflower, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Your Journey',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: _linen),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Big streak number
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$streakDays',
                        style: TextStyle(
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: ' -Day Streak',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'days strong',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.7)),
                ),
                SizedBox(height: 12.h),

                // Stars + date badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(4, (_) => Icon(Icons.star_rounded, color: _sunflower, size: 16.sp)),
                      Icon(Icons.star_half_rounded, color: _sunflower, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(dateStr, style: TextStyle(fontSize: 11.sp, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Right: Small Hopi Avatar ───
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: _emerald.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/hopi/hopi_idle_smiling.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
