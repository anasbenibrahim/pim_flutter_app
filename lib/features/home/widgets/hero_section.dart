import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../hopi/cubit/hopi_state.dart';
import '../../hopi/widgets/hopi_character.dart';
import 'typewriter_dialogue.dart';

// ═══════════════════════════════════════════
// Brand Palette
// ═══════════════════════════════════════════
const _indigo = Color(0xFF022F40);

// ═══════════════════════════════════════════
// Named Layout Constants — tweak these to reposition
// ═══════════════════════════════════════════

/// Total height of the hero "stage" container.
/// This is the bounding box — Hopi + branch are layered inside it.
/// Increase = taller stage area, decrease = shorter.
const double STAGE_HEIGHT = 150;

/// Size of the Hopi character (width & height).
/// Hopi can exceed STAGE_HEIGHT — he'll just overflow (clipped to the stage).
const double CHARACTER_SIZE = 250;

/// Bottom offset of Hopi inside the Stack.
/// Higher value = Hopi moves UP, lower = Hopi moves DOWN.
const double CHARACTER_BOTTOM = -20;

/// Horizontal nudge for Hopi relative to center.
/// Positive = shift right, negative = shift left.
const double CHARACTER_HORIZONTAL_NUDGE = -10;

/// Width of the branch image (>100% of screen for natural look).
const double BRANCH_WIDTH = 400;

/// Bottom offset of the branch inside the Stack.
/// Higher value = branch moves UP.
const double BRANCH_BOTTOM = -140;

/// Horizontal offset of the branch from center.
/// Negative = shift left, positive = shift right.
const double BRANCH_HORIZONTAL_OFFSET = -40;

/// The top padding above the "HopeUp" logo.
const double LOGO_TOP_PADDING = 8;

/// Space between logo and the stage.
const double LOGO_TO_STAGE_GAP = 10;

/// HeroSection — Hopi sitting on a tree branch.
///
/// Architecture (Stack-based):
///   A Column stacks vertically:
///     1. "HopeUp" logo (top-left)
///     2. A fixed-height Container ("the stage") containing a Stack:
///        - Track 1 (bottom layer): Branch image, Positioned at bottom
///        - Track 2 (top layer):    Hopi character, Positioned on the branch
///
///   Using a Stack ensures that increasing Hopi's size does NOT push
///   the "Your Journey" card or any content below it downward.
///   The hero scene stays contained in its fixed-height box.
class HeroSection extends StatelessWidget {
  final HopiStateData hopiState;
  final String? moodState;
  final String userName;
  final bool showGreeting;
  final VoidCallback? onHopiTapped;

  const HeroSection({
    super.key, 
    required this.hopiState, 
    required this.userName,
    this.showGreeting = true,
    this.moodState,
    this.onHopiTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── "HopeUp" Logo ───
        Padding(
          padding: EdgeInsets.only(left: 20.w, top: LOGO_TOP_PADDING.h, right: 20.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HopeUp',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w900,
                color: _indigo,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        SizedBox(height: LOGO_TO_STAGE_GAP.h),

        // ─── The "Stage" — fixed-height box with layered content ───
        _buildStage(),
      ],
    );
  }

  /// The stage: a fixed-height Container with a Stack inside.
  /// Hopi and the branch are layered using Positioned widgets.
  Widget _buildStage() {
    return Container(
      height: STAGE_HEIGHT.h,
      width: double.infinity,
      // clipBehavior: Clip.none, // ← uncomment to let Hopi overflow the stage
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // allow Hopi to visually overflow if larger than stage
        children: [
          // ─── Track 1: THE FLOOR (Branch) ───
          Positioned(
            bottom: BRANCH_BOTTOM.h,
            left: BRANCH_HORIZONTAL_OFFSET.w,
            child: SizedBox(
              width: BRANCH_WIDTH.w,
              child: Image.asset(
                'assets/hopi/animation videos/branch_day.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ─── Track 2: THE ACTOR (Hopi) ───
          Positioned(
            bottom: CHARACTER_BOTTOM.h,
            child: Transform.translate(
              offset: Offset(CHARACTER_HORIZONTAL_NUDGE.w, 0),
              child: _buildHopi(),
            ),
          ),

          // ─── Track 3: The Dialogue Bubble ───
          if (moodState != null || showGreeting)
            Positioned(
              bottom: (CHARACTER_BOTTOM + CHARACTER_SIZE * 0.55).h, // Keep height
              left: (BRANCH_HORIZONTAL_OFFSET + CHARACTER_SIZE * 0.70).w, // Pushed right to clear head
              child: _buildDialogue(),
            ),
        ],
      ),
    );
  }

  Widget _buildHopi() {
    Widget hopiWidget;
    if (moodState == 'Anxious') {
      hopiWidget = Image.asset(
        'assets/hopi/animation videos/hopi-anxious.webp',
        width: CHARACTER_SIZE,
        height: CHARACTER_SIZE,
        fit: BoxFit.contain,
      );
    } else {
      // Default to the idle Hopi via HopiCharacter or explicitly sleep for Fatigued
      // Since 'sleepy' asset isn't explicitly provided except hapi_idle_tpbg.webp,
      // we use the existing HopiCharacter logic as fallback.
      hopiWidget = HopiCharacter(
        mood: hopiState.mood,
        size: CHARACTER_SIZE,
      );
    }

    return GestureDetector(
      onTap: onHopiTapped,
      child: hopiWidget,
    );
  }

  Widget _buildDialogue() {
    String text = '';
    if (moodState == 'Anxious') {
      text = 'I feel a bit tense... \nShall we take a deep breath together?';
    } else if (moodState == 'Fatigued') {
      text = 'I feel a bit sluggish today. \nMaybe we should get some rest?';
    } else if (moodState == 'Balanced') {
      text = 'I feel alert and ready to grow! \nWhat are we doing next?';
    } else {
      text = 'Hi $userName! \nI\'m so glad you\'re here today.';
    }

    return TypewriterDialogue(
      text: text,
      charDelay: const Duration(milliseconds: 30),
    );
  }
}

