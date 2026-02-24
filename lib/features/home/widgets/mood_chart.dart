import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════
// Brand Palette
// ═══════════════════════════════════════════
const _emerald = Color(0xFF46C67D);
const _indigo  = Color(0xFF022F40);
const _linen   = Color(0xFFF2EBE1);

/// Mood Journey section — weekly bezier line chart with emerald line.
class MoodChart extends StatelessWidget {
  const MoodChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Journey',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _linen),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: _indigo.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Trend',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8)),
                  ),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: _emerald.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/hopi/hopi_idle_smiling.png', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Bezier chart
              SizedBox(
                height: 80.h,
                child: CustomPaint(
                  size: Size(double.infinity, 80.h),
                  painter: _BezierChartPainter(),
                ),
              ),
              SizedBox(height: 12.h),

              // Day labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((d) => Text(d, style: TextStyle(fontSize: 10.sp, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w500)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter — draws a smooth bezier mood line with gradient fill and glow dots.
class _BezierChartPainter extends CustomPainter {
  // Sample data (0.0 = low mood, 1.0 = high mood)
  final List<double> _data = const [0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.75];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final step = w / (_data.length - 1);

    // Map data to pixel coordinates
    final points = <Offset>[
      for (int i = 0; i < _data.length; i++)
        Offset(step * i, h - (_data[i] * h)),
    ];

    // ─── Gradient fill under curve ───
    final fillPath = Path()..moveTo(0, h);
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      fillPath.cubicTo(
        points[i].dx + step * 0.4, points[i].dy,
        points[i + 1].dx - step * 0.4, points[i + 1].dy,
        points[i + 1].dx, points[i + 1].dy,
      );
    }
    fillPath.lineTo(w, h);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_emerald.withOpacity(0.3), _emerald.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // ─── Bezier line ───
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      linePath.cubicTo(
        points[i].dx + step * 0.4, points[i].dy,
        points[i + 1].dx - step * 0.4, points[i + 1].dy,
        points[i + 1].dx, points[i + 1].dy,
      );
    }
    canvas.drawPath(linePath, Paint()
      ..color = _emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // ─── Glow dots ───
    for (final p in points) {
      canvas.drawCircle(p, 5, Paint()..color = _emerald.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      canvas.drawCircle(p, 3, Paint()..color = _emerald);
      canvas.drawCircle(p, 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
