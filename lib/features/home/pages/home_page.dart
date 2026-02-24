import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../hopi/cubit/hopi_cubit.dart';
import '../../hopi/cubit/hopi_state.dart';
import '../widgets/hero_section.dart';
import '../widgets/stats_card.dart';
import '../widgets/action_grid.dart';
import '../widgets/mood_chart.dart';

// ═══════════════════════════════════════════
// Brand Palette — BBRC Colour Board
// ═══════════════════════════════════════════
const _sapphire = Color(0xFF0D6078);
const _indigo   = Color(0xFF022F40);

// ═══════════════════════════════════════════
// Dynamic Background Gradients
// ═══════════════════════════════════════════
const _forestGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFB5DDE6), // Light sapphire tint
    Color(0xFF5BA8B8), // Mid sapphire
    Color(0xFF0D6078), // Sapphire
    Color(0xFF053545), // Transition
    Color(0xFF022F40), // Indigo
  ],
  stops: [0.0, 0.2, 0.45, 0.75, 1.0],
);

const _anxiousGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFF9CBBF), // Light brick tint
    Color(0xFFF9876E), // Mid brick
    Color(0xFFF9623E), // Brick
    Color(0xFF8B2B15), // Dark Transition
    Color(0xFF022F40), // Indigo Base
  ],
  stops: [0.0, 0.2, 0.45, 0.75, 1.0],
);

const _fatiguedGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF4C6D7A), // Muted dark blue
    Color(0xFF1E4656), // Deeper blue
    Color(0xFF0D3646), // Darker transition
    Color(0xFF022F40), // Indigo Base
    Color(0xFF01151D), // Very dark
  ],
  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
);

/// HopeUp Home Screen — Forest Theme
///
///  Structure (top → bottom):
///    A. [HeroSection]  — Hopi sitting on a branch
///    B. [StatsCard]    — "Your Journey" streak card
///    C. [ActionGrid]   — Quick actions (Journal, Mood-in, SOS, Support)
///    D. [MoodChart]    — Weekly bezier mood chart
///
///  The Floating Bottom Nav lives in [MainNavigationPage], outside the scroll.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _moodState; // Stores 'Anxious', 'Fatigued', or 'Balanced' after playing Focus Garden
  bool _showGreeting = true; // Show greeting on initial load

  @override
  void initState() {
    super.initState();
    _loadMoodState();
    
    // Hide the greeting after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showGreeting = false;
        });
      }
    });
  }

  Future<void> _loadMoodState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _moodState = prefs.getString('hopi_active_mood_state');
      });
    }
  }

  // Expose a setter so child widgets (like ActionGrid) can update it
  Future<void> setMoodState(String? mood) async {
    setState(() {
      _moodState = mood;
    });
    
    final prefs = await SharedPreferences.getInstance();
    if (mood == null) {
      await prefs.remove('hopi_active_mood_state');
    } else {
      await prefs.setString('hopi_active_mood_state', mood);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Light status bar text on the dark gradient
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator(color: _sapphire, strokeWidth: 2));
        }

        return BlocBuilder<HopiCubit, HopiStateData>(
          builder: (context, hopiState) {
            // Calculate streak from sobriety date
            final streakDays = authState.user.sobrietyDate != null
                ? DateTime.now().difference(authState.user.sobrietyDate!).inDays
                : 7;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: _moodState == 'Anxious' 
                      ? _anxiousGradient 
                      : _moodState == 'Fatigued' 
                          ? _fatiguedGradient 
                          : _forestGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    // CRITICAL: paddingBottom so last card scrolls above floating nav
                    padding: EdgeInsets.only(bottom: 120.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Hero Scene (Now reactive to _moodState)
                        HeroSection(
                          hopiState: hopiState, 
                          moodState: _moodState,
                          userName: authState.user.prenom,
                          showGreeting: _showGreeting,
                          onHopiTapped: () {
                            String? nextState;
                            if (_moodState == 'Anxious') {
                              nextState = 'Balanced';
                            } else if (_moodState == 'Fatigued') {
                              nextState = 'Balanced';
                            } else {
                              nextState = 'Anxious'; // Cycle for testing
                            }
                            setMoodState(nextState);
                          }
                        ),

                        // B. Journey Card
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: StatsCard(streakDays: streakDays),
                        ),
                        SizedBox(height: 24.h),

                        // C. Quick Actions
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: ActionGrid(
                            onGameFinished: (state) => setMoodState(state),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // D. Mood Journey
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const MoodChart(),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
