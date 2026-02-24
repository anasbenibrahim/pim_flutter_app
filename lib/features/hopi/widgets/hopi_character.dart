import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/hopi_cubit.dart';
import '../cubit/hopi_state.dart';

/// Animated Hopi character widget.
///
/// Displays the correct animated WebP based on [mood].
/// Tapping Hopi triggers a bounce animation + haptic feedback.
class HopiCharacter extends StatefulWidget {
  final HopiMood mood;
  final double size;

  const HopiCharacter({
    super.key,
    required this.mood,
    this.size = 180,
  });

  @override
  State<HopiCharacter> createState() => _HopiCharacterState();
}

class _HopiCharacterState extends State<HopiCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    _bounceController.forward(from: 0);

    // Toggle: idle → happy, happy → idle
    final cubit = context.read<HopiCubit>();
    if (widget.mood == HopiMood.idle) {
      cubit.setMood(HopiMood.happy);
    } else if (widget.mood == HopiMood.happy) {
      cubit.setMood(HopiMood.idle);
    }
  }

  /// Get the asset path for the current mood.
  String _assetForMood(HopiMood mood) {
    // All moods fall back to the transparent idle animation for now.
    // Add mood-specific files as they're created:
    //   assets/hopi/hapi_happy_tpbg.webp
    //   assets/hopi/hapi_anxious_tpbg.webp
    //   etc.
    switch (mood) {
      case HopiMood.happy:
        return 'assets/hopi/Hopi_happy.webp';
      case HopiMood.idle:
        return 'assets/hopi/hapi_idle_tpbg.webp';
      case HopiMood.anxious:
        return 'assets/hopi/hapi_idle_tpbg.webp';
      case HopiMood.sad:
        return 'assets/hopi/hapi_idle_tpbg.webp';
      case HopiMood.angry:
        return 'assets/hopi/hapi_idle_tpbg.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _bounceAnimation,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            _assetForMood(widget.mood),
            key: ValueKey(widget.mood),
            width: widget.size.w,
            height: widget.size.w,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.pets,
              size: widget.size.w * 0.5,
              color: HopiPalette.forMood(widget.mood).primary,
            ),
          ),
        ),
      ),
    );
  }
}
