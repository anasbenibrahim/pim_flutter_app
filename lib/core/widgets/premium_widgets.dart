import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'dart:math' as Math;
import '../theme/app_colors.dart';
export 'custom_app_bar.dart';

class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Color
        Container(color: AppColors.getMeshBaseColor(context)),
        
        // Mesh Gradient Orbs
        Positioned(
          top: -100,
          right: -100,
          child: _GlowOrb(
            color: const Color(0xFF6200EE).withOpacity(0.5),
            size: 400.w,
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100.w,
          child: _GlowOrb(
            color: const Color(0xFF03DAC6).withOpacity(0.3),
            size: 350.w,
          ),
        ),
        Positioned(
          top: 200.h,
          left: -50.w,
          child: _GlowOrb(
            color: const Color(0xFFBB86FC).withOpacity(0.2),
            size: 300.w,
          ),
        ),

        // Blur Layer
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),

        // Content
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          stops: const [0.3, 1.0],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsets? padding;

  const GlassCard({
    super.key, 
    required this.child, 
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.getGlassColor(context),
            borderRadius: BorderRadius.circular(borderRadius ?? 24.r),
            border: Border.all(
              color: AppColors.getGlassBorder(context),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class PremiumTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const PremiumTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getPremiumTextSecondary(context),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(color: AppColors.getPremiumText(context), fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.getPremiumTextSecondary(context).withOpacity(0.5), fontSize: 14.sp),
                prefixIcon: prefixIcon != null 
                    ? Icon(prefixIcon, color: AppColors.primaryPurple, size: 20.sp) 
                    : null,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: AppColors.getGlassColor(context),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.getGlassBorder(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: AppColors.getGlassBorder(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PremiumScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  const PremiumScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return MeshGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: SafeArea(
          bottom: false, // Let navigation bar handle bottom padding if needed
          child: body,
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

class HopeUpLogo extends StatefulWidget {
  final double size;
  const HopeUpLogo({super.key, this.size = 200});

  @override
  State<HopeUpLogo> createState() => _HopeUpLogoState();
}

class _HopeUpLogoState extends State<HopeUpLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size.w,
          height: widget.size.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dynamic Aura
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.15),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00F2FE).withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: -10,
                    ),
                  ],
                ),
              ),
              
              // Custom Painted Glass Orb
              CustomPaint(
                size: Size(widget.size.w, widget.size.w),
                painter: _LogoPainter(progress: _controller.value, context: context),
              ),
              
              // Central "Hope" Light
              Container(
                width: widget.size * 0.15,
                height: widget.size * 0.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AppColors.primaryPurple,
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  _LogoPainter({required this.progress, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // 1. Draw Outer Glass Shell
    final shellPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.05),
          AppColors.primaryPurple.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, shellPaint);

    // 2. Draw Rotating Energy Orbits (Intricate Petals)
    for (int i = 0; i < 3; i++) {
        final orbitProgress = (progress + (i / 3)) % 1.0;
        final orbitPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..shader = SweepGradient(
            colors: [
              Colors.transparent,
              AppColors.primaryPurple.withOpacity(0.5),
              const Color(0xFF00F2FE).withOpacity(0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.6, 1.0],
            transform: GradientRotation(orbitProgress * 6.28),
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));

        final path = Path();
        for (double t = 0; t <= 6.28; t += 0.05) {
            double r = radius * (0.8 + 0.2 * Math.sin(t * 3 + orbitProgress * 6.28));
            double x = center.dx + r * Math.cos(t);
            double y = center.dy + r * Math.sin(t);
            if (t == 0) path.moveTo(x, y); else path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, orbitPaint);
    }

    // 3. Draw Highlights (Shine)
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, shinePaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) => oldDelegate.progress != progress;
}

class PremiumSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const PremiumSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.getPremiumText(context),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class FloatingGlassNavBar extends StatelessWidget {
  final Widget child;
  final double? margin;

  const FloatingGlassNavBar({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, margin ?? 24.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.getGlassColor(context).withOpacity(0.15),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: AppColors.getGlassBorder(context).withOpacity(0.3),
                width: 0.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.getGlassColor(context).withOpacity(0.1),
                  AppColors.getGlassColor(context).withOpacity(0.05),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
