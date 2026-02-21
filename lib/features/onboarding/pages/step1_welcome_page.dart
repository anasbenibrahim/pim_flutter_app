import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);

class WelcomePage extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/images/welcome_video.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoController.play();
        }
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _linen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),

              // ─── Brand ───
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [_sapphire, _emerald],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'HopeUp',
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // ─── Video ───
              Expanded(
                flex: 4,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: child,
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: _videoReady
                        ? AspectRatio(
                            aspectRatio: _videoController.value.aspectRatio,
                            child: VideoPlayer(_videoController),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: _sapphire.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _sapphire,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ─── Copy ───
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(opacity: value, child: child);
                },
                child: Column(
                  children: [
                    Text(
                      "Welcome to HopeUp",
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: _indigo,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "You've taken the first step — and that takes courage.\nWe're here to walk beside you, one day at a time.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _indigo.withOpacity(0.45),
                        height: 1.65,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // ─── CTA ───
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _sapphire,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let's Begin",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, size: 20.sp),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
