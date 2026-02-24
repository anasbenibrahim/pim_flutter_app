import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

const _emerald   = Color(0xFF46C67D);
const _indigo    = Color(0xFF022F40);
const _sunflower = Color(0xFFF8C929);

class _HobbyItem {
  final String id;
  final String emoji;
  final String label;
  const _HobbyItem(this.id, this.emoji, this.label);
}

const _hobbies = [
  _HobbyItem('MUSIC',       '🎵', 'Musique'),
  _HobbyItem('SPORT',       '⚽', 'Sport'),
  _HobbyItem('GAMING',      '🎮', 'Gaming'),
  _HobbyItem('READING',     '📖', 'Lecture'),
  _HobbyItem('ART',         '🎨', 'Art'),
  _HobbyItem('MEDITATION',  '🧘', 'Méditation'),
  _HobbyItem('COOKING',     '🍳', 'Cuisine'),
  _HobbyItem('NATURE',      '🌿', 'Nature'),
  _HobbyItem('PHOTOGRAPHY', '📸', 'Photo'),
  _HobbyItem('TRAVEL',      '✈️', 'Voyage'),
  _HobbyItem('TECH',        '💻', 'Tech'),
  _HobbyItem('PETS',        '🐕', 'Animaux'),
];

class Page2Hobbies extends StatelessWidget {
  final VoidCallback onNext;
  const Page2Hobbies({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12.h),

                // ─── Progress Dots ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => Container(
                    width: i == 1 ? 24.w : 8.w,
                    height: 8.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: i <= 1 ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  )),
                ),
                SizedBox(height: 16.h),

                // ─── Hopi Character ───
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, val, child) => Transform.scale(scale: val, child: child),
                  child: Image.asset(
                    'assets/hopi/Hopi_happy.webp',
                    height: 100.h,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 12.h),

                // ─── Header ───
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    children: [
                      Text(
                        'Ton Jardin de Hobbies 🌻',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Choisis les activités qui te rendent heureux·se !',
                        style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // ─── Hobby Grid ───
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _hobbies.length,
                      itemBuilder: (context, index) {
                        final hobby = _hobbies[index];
                        final selected = state.hobbies.contains(hobby.id);
                        return _HobbyTile(
                          hobby: hobby,
                          selected: selected,
                          onTap: () => context.read<OnboardingBloc>().add(HobbyToggled(hobby.id)),
                        );
                      },
                    ),
                  ),
                ),

                // ─── Counter & CTA ───
                Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 8.h, 28.w, 20.h),
                  child: Column(
                    children: [
                      if (state.hobbies.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Text(
                            '${state.hobbies.length} sélectionné${state.hobbies.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: _sunflower.withAlpha(230),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.hobbies.isNotEmpty ? onNext : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _emerald,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _emerald.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continuer', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                              SizedBox(width: 8.w),
                              Icon(Icons.arrow_forward_rounded, size: 18.sp),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HobbyTile extends StatefulWidget {
  final _HobbyItem hobby;
  final bool selected;
  final VoidCallback onTap;

  const _HobbyTile({required this.hobby, required this.selected, required this.onTap});

  @override
  State<_HobbyTile> createState() => _HobbyTileState();
}

class _HobbyTileState extends State<_HobbyTile> with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_HobbyTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnim.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: widget.selected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: widget.selected ? _sunflower : Colors.white.withOpacity(0.2),
              width: widget.selected ? 2.5 : 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: _sunflower.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.hobby.emoji,
                style: TextStyle(fontSize: 32.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                widget.hobby.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
                  color: widget.selected ? _indigo : Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
