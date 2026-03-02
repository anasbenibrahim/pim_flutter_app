import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final double zoom;
  const CosmicBackground({super.key, required this.child, this.zoom = 1.0});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ─── The Cosmic Layer ───
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _CosmicPainter(
                  progress: _controller.value,
                  zoom: widget.zoom,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                ),
              );
            },
          ),
        ),
        // ─── The Content ───
        widget.child,
      ],
    );
  }
}

class _CosmicPainter extends CustomPainter {
  final double progress;
  final double zoom;
  final bool isDarkMode;

  _CosmicPainter({required this.progress, required this.zoom, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint();

    // ─── 1. Background Gradient ───
    final bgGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.5 * zoom,
      colors: isDarkMode 
        ? [const Color(0xFF0D1B2A), const Color(0xFF040609)]
        : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
    );
    paint.shader = bgGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // ─── 2. Stars ───
    final random = math.Random(42); // Seeded for consistency
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2.0 * zoom;
      final opacity = (math.sin(progress * 2 * math.pi + random.nextDouble() * 10) * 0.5 + 0.5) * (isDarkMode ? 0.8 : 0.3);
      
      paint.shader = null;
      paint.color = (isDarkMode ? Colors.white : AppColors.sapphire).withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }

    // ─── 3. Orbital Rings ───
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      final radius = (size.width * 0.3 * i) * zoom;
      final rotation = progress * 2 * math.pi * (i.isEven ? 1 : -1) * 0.1;
      
      paint.color = AppColors.sapphire.withOpacity(isDarkMode ? 0.1 : 0.05);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 1.2), paint);
      canvas.restore();
    }

    // ─── 4. Glowing Nebulosity ───
    paint.style = PaintingStyle.fill;
    final nebulaGradient = RadialGradient(
      colors: [
        AppColors.sapphire.withOpacity(isDarkMode ? 0.15 : 0.05),
        Colors.transparent,
      ],
    );
    paint.shader = nebulaGradient.createShader(Rect.fromCircle(center: center, radius: size.width * 0.8 * zoom));
    canvas.drawCircle(center, size.width * 0.8 * zoom, paint);
  }

  @override
  bool shouldRepaint(_CosmicPainter oldDelegate) => true;
}
