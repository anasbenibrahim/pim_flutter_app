import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/routes/app_routes.dart';

// ─── HopeUp Color Palette ───
const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _brick     = Color(0xFFF9623E);
const _sunflower = Color(0xFFF8C929);

class WelcomeCarouselPage extends StatefulWidget {
  const WelcomeCarouselPage({super.key});

  @override
  State<WelcomeCarouselPage> createState() => _WelcomeCarouselPageState();
}

class _WelcomeCarouselPageState extends State<WelcomeCarouselPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_SlideData> _slides = const [
    _SlideData(
      step: 'Étape 1',
      bgColor: _sapphire,
      accentColor: _emerald,
      imagePath: 'assets/images/Illustration.png',
      title: 'Suivez votre parcours\nde rétablissement',
      subtitle:
          'HopeUp vous accompagne jour après jour vers une sobriété durable, avec empathie et intelligence.',
    ),
    _SlideData(
      step: 'Étape 2',
      bgColor: _indigo,
      accentColor: _sunflower,
      imagePath: 'assets/images/face.png',
      title: 'Suivi intelligent\n& alertes personnalisées',
      subtitle:
          'Notre IA analyse votre humeur, vos habitudes et vous envoie des notifications d\'encouragement au bon moment.',
    ),
    _SlideData(
      step: 'Étape 3',
      bgColor: _linen,
      accentColor: _brick,
      imagePath: 'assets/images/illustration_4.png',
      title: 'Une communauté\nqui vous comprend',
      subtitle:
          'Connectez-vous avec des volontaires, des familles et des personnes qui partagent votre parcours.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.getStarted);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final bool isLightBg = slide.bgColor == _linen;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: slide.bgColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── Top Bar ───
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: (isLightBg ? _indigo : Colors.white).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        slide.step,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: isLightBg ? _indigo : Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _skip,
                      child: Text(
                        'Passer',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isLightBg ? _sapphire : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Illustration Area (Swipeable) ───
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final s = _slides[index];
                    return _buildIllustration(s);
                  },
                ),
              ),

              // ─── Bottom Content Sheet ───
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isLightBg ? Colors.white : _linen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(32.w, 32.h, 32.w, 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot Indicators
                    Row(
                      children: List.generate(
                        _slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: 8.w),
                          height: 6.h,
                          width: i == _currentPage ? 28.w : 10.w,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? _sapphire
                                : _sapphire.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    Text(
                      slide.title,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: _indigo,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _indigo.withOpacity(0.55),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Arrow Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          height: 56.h,
                          width: 56.h,
                          decoration: BoxDecoration(
                            color: _sapphire,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _sapphire.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(_SlideData slide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      child: Center(
        child: Image.asset(
          slide.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image not found
            final isLight = slide.bgColor == _linen;
            return Container(
              width: 140.w, height: 140.w,
              decoration: BoxDecoration(
                color: (isLight ? _sapphire : Colors.white).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_rounded,
                size: 64.sp,
                color: isLight ? _indigo : Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SlideData {
  final String step;
  final Color bgColor;
  final Color accentColor;
  final String imagePath;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.step,
    required this.bgColor,
    required this.accentColor,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
