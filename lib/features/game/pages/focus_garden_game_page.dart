import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/api_service.dart';

const _indigo = Color(0xFF022F40);
const _sunflower = Color(0xFFF8C929);
const _brick = Color(0xFFF9623E);

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

class FocusGardenGamePage extends StatefulWidget {
  const FocusGardenGamePage({super.key});

  @override
  State<FocusGardenGamePage> createState() => _FocusGardenGamePageState();
}

class _FocusGardenGamePageState extends State<FocusGardenGamePage> {
  // Game Settings
  static const int _totalRounds = 5;
  static const int _minDelayMs = 2000;
  static const int _maxDelayMs = 5000;

  // Game State
  int _currentRound = 0;
  bool _isPlaying = false;
  bool _isStimulusVisible = false;
  bool _isFinished = false;

  // Timers and Data
  Timer? _delayTimer;
  Timer? _uiTimer;
  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();

  final List<int> _reactionTimes = [];
  int _falseStarts = 0;
  int _currentMs = 0;

  // Stimulus Coordinates
  double _stimulusX = 0;
  double _stimulusY = 0;

  bool _showInstructions = true;
  String _hopiFeedback = '';

  @override
  void initState() {
    super.initState();
    // Do not start immediately; wait for user to dismiss instructions
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _uiTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startNextRound() {
    if (!mounted) return;

    setState(() {
      _isPlaying = true;
      _isStimulusVisible = false;
    });

    final delay = _minDelayMs + _random.nextInt(_maxDelayMs - _minDelayMs);

    _delayTimer = Timer(Duration(milliseconds: delay), _showStimulus);
  }

  void _showStimulus() {
    if (!mounted) return;

    // Calculate a random position on the screen, keeping it away from edges
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Hopi is in the center (approx 200x200). Avoid the center.
    // For simplicity, just spawn anywhere in the safe area margins.
    _stimulusX = 40.w + _random.nextDouble() * (screenWidth - 120.w);
    _stimulusY = 100.h + _random.nextDouble() * (screenHeight - 300.h);

    setState(() {
      _isStimulusVisible = true;
    });

    _stopwatch.reset();
    _stopwatch.start();
    
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentMs = _stopwatch.elapsedMilliseconds;
        });
      }
    });
  }

  void _handleScreenTap() {
    if (!_isPlaying) return;

    if (!_isStimulusVisible) {
      // False Start
      _delayTimer?.cancel();
      _falseStarts++;
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: const Text('Oups ! Trop tôt. Patientez jusqu\'à ce que la fleur apparaisse.'),
          backgroundColor: _brick,
          duration: const Duration(milliseconds: 1500),
        ),
      );

      // Restart the same round
      setState(() { _isPlaying = false; });
      Future.delayed(const Duration(milliseconds: 1500), _startNextRound);
      return;
    }

    // Valid Tap on background (Missed the flower)? 
    // Wait, the user has to tap the FLOWER specifically.
    // If we want any screen tap to count (easier PVT), we handle it here.
    // Standard PVT allows hitting the button/screen. Let's make them hit the screen anywhere for now,
    // or specifically the flower? Standard PVT = hit anywhere. The requirement says "User taps the flower."
    // Let's implement specific flower tap. So background tap while stimulus is visible does nothing or is a penalty.
    // Let's ignore background taps when stimulus is visible, to force tapping the flower.
  }

  void _handleFlowerTap() {
    if (!_isStimulusVisible) return;

    _uiTimer?.cancel();
    _stopwatch.stop();
    final rt = _stopwatch.elapsedMilliseconds;
    _reactionTimes.add(rt);

    String feedback = '';
    if (rt < 280) {
      feedback = 'Lightning fast! ⚡️';
    } else if (rt > 350) {
      feedback = 'Take your time, breathe. 🍃';
    } else {
      feedback = 'Nice catch! 🌻';
    }

    setState(() {
      _currentMs = rt;
      _isStimulusVisible = false;
      _isPlaying = false;
      _hopiFeedback = feedback;
      _currentRound++;
    });

    if (_currentRound >= _totalRounds) {
      Future.delayed(const Duration(milliseconds: 1500), _finishGame);
    } else {
      // Brief pause before next round to show feedback
      Future.delayed(const Duration(milliseconds: 2000), _startNextRound);
    }
  }

  void _finishGame() async {
    if (!mounted) return;
    setState(() => _isFinished = true);

    final moodState = _calculateMoodState();
    
    // Save to backend silently
    try {
      await ApiService().saveGameLog(
        gameType: 'Focus Garden',
        rawData: _reactionTimes,
        derivedState: moodState,
      );
    } catch (e) {
      debugPrint('Failed to save game log: $e');
    }

    // Return the state to the Home Screen
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) Navigator.pop(context, moodState);
    });
  }

  String _calculateMoodState() {
    if (_reactionTimes.isEmpty) return 'Balanced';

    int sum = _reactionTimes.reduce((a, b) => a + b);
    double avg = sum / _reactionTimes.length;

    // Calculate Standard Deviation
    double sumVariance = 0;
    for (int rt in _reactionTimes) {
      sumVariance += pow(rt - avg, 2);
    }
    double stdDev = sqrt(sumVariance / _reactionTimes.length);

    int lapses = _reactionTimes.where((rt) => rt > 500).length;

    if (_falseStarts >= 3 || stdDev > 150) {
      return 'Anxious';
    } else if (avg > 350 || lapses > 1) {
      return 'Fatigued';
    } else if (avg < 280 && _falseStarts < 2) {
      return 'Balanced';
    }

    // Default middle ground
    return 'Balanced';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: _forestGradient),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleScreenTap,
          child: Stack(
            children: [
            // Center Hopi
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isFinished ? 0.0 : 1.0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 10),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOutSine,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value - 5),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/hopi/hapi_idle_tpbg.webp',
                    height: 200.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Round Counter & Timer
            Positioned(
              top: 60.h,
              left: 24.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round ${_currentRound < _totalRounds ? _currentRound + 1 : _totalRounds}/$_totalRounds',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  if (_currentRound < _totalRounds && !_showInstructions) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '${(_currentMs / 1000).toStringAsFixed(3)} s',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Back button
            Positioned(
              top: 50.h,
              right: 16.w,
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5), size: 28.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // The Stimulus (Sunflower)
            if (_isStimulusVisible)
              Positioned(
                left: _stimulusX,
                top: _stimulusY,
                child: GestureDetector(
                  onTap: _handleFlowerTap,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: _sunflower.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset(
                      'assets/images/sunflower.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.wb_sunny_rounded, color: _sunflower, size: 40.sp);
                      },
                    ),
                  ),
                ),
              ),

              // End Screen transition overlay
              if (_isFinished)
                Container(
                  color: _indigo.withOpacity(0.9), // Add opacity so gradient peaks through slightly
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, color: _sunflower, size: 64.sp),
                        SizedBox(height: 24.h),
                        Text(
                          'Analyse en cours...',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

              // Hopi's Feedback Bubble
              if (_hopiFeedback.isNotEmpty && !_isFinished && !_isStimulusVisible && !_showInstructions)
                Positioned(
                  bottom: screenHeight * 0.25,
                  left: 20.w,
                  right: 20.w,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Text(
                        _hopiFeedback,
                        style: TextStyle(
                          color: _indigo,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              // Instructional Popup
              if (_showInstructions)
                Container(
                  color: _indigo.withOpacity(0.85),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Container(
                        padding: EdgeInsets.all(32.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_vintage_rounded, color: _sunflower, size: 48.sp),
                            SizedBox(height: 16.h),
                            Text(
                              'Focus Garden',
                              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: _indigo),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Wait for the sunflower to appear.\n\nTap it as quickly as possible!\n\nDon\'t tap the screen before it blooms!',
                              style: TextStyle(fontSize: 16.sp, color: _indigo.withOpacity(0.8), height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 32.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _indigo,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showInstructions = false;
                                    _hopiFeedback = 'Let\'s go!';
                                  });
                                  Future.delayed(const Duration(milliseconds: 1000), _startNextRound);
                                },
                                child: Text('Start', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
      ),
    );
  }
}
