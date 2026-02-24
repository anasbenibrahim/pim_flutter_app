import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

const _sapphire  = Color(0xFF0D6078);
const _linen     = Color(0xFFF2EBE1);
const _indigo    = Color(0xFF022F40);
const _emerald   = Color(0xFF46C67D);
const _sunflower = Color(0xFFF8C929);

class Page4Referral extends StatefulWidget {
  final VoidCallback onFinish;
  const Page4Referral({super.key, required this.onFinish});

  @override
  State<Page4Referral> createState() => _Page4ReferralState();
}

class _Page4ReferralState extends State<Page4Referral> with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  bool _showSuccess = false;
  late AnimationController _hopiCtrl;
  late Animation<double> _hopiBounce;

  @override
  void initState() {
    super.initState();
    _hopiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hopiBounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _hopiCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _hopiCtrl.dispose();
    super.dispose();
  }

  void _handleFinish() {
    setState(() => _showSuccess = true);
    _hopiCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _linen,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 12.h),

                  // ─── Progress Dots ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: i == 3 ? 24.w : 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: _sapphire,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    )),
                  ),
                  SizedBox(height: 40.h),

                  // ─── Hopi ───
                  AnimatedBuilder(
                    animation: _hopiBounce,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _showSuccess ? _hopiBounce.value : 1.0,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      _showSuccess
                          ? 'assets/hopi/Hopi_happy.webp'
                          : 'assets/hopi/hopi_idle_smiling.png',
                      height: 120.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ─── Header ───
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _showSuccess
                        ? Column(
                            key: const ValueKey('success'),
                            children: [
                              Text(
                                '🎉',
                                style: TextStyle(fontSize: 40.sp),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Bienvenue sur HopeUp !',
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _indigo,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Ton profil est prêt.\nHopi t\'attend sur ta branche !',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _indigo.withOpacity(0.5),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey('form'),
                            children: [
                              Text(
                                'Dernière étape 🏁',
                                style: TextStyle(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _indigo,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'As-tu un code de parrainage ?\nSi oui, entre-le ci-dessous.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _indigo.withOpacity(0.45),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 32.h),

                  // ─── Referral Code Input ───
                  if (!_showSuccess) ...[
                    TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _indigo,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: 'CODE PARRAINAGE',
                        hintStyle: TextStyle(
                          color: _indigo.withOpacity(0.2),
                          fontSize: 16.sp,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: _indigo.withOpacity(0.08)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: _indigo.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: _sapphire, width: 1.5),
                        ),
                      ),
                      onChanged: (val) => context.read<OnboardingBloc>().add(ReferralCodeChanged(val.trim())),
                    ),
                    SizedBox(height: 28.h),

                    // ─── Finish Button ───
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emerald,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Terminer',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.check_rounded, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ─── Skip ───
                    TextButton(
                      onPressed: _handleFinish,
                      child: Text(
                        'Passer cette étape',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _indigo.withOpacity(0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
