import 'package:flutter_bloc/flutter_bloc.dart';
import 'hopi_state.dart';

/// Cubit that manages Hopi's composite mood score.
///
/// Hopi's mood is a weighted average of:
///   - Daily mood log (30%)
///   - Streak consistency (20%)
///   - Sleep quality from smartwatch (15%)
///   - Activity level from smartwatch (10%)
///   - Mini-game performance (10%)
///   - Journal sentiment (10%)
///   - Heart rate variability (5%)
///
/// For now, mood is driven by user mood logs + streak.
/// Other inputs will be added as Sprint 4–5 features.
class HopiCubit extends Cubit<HopiStateData> {
  HopiCubit() : super(HopiStateData.initial());

  /// Update from a user mood log (1–10 scale, converted to 0–100).
  void updateFromMoodLog(int moodScore) {
    final normalized = (moodScore / 10.0) * 100.0;
    _recalculate(moodLog: normalized);
  }

  /// Update from streak count (more days = higher contribution).
  void updateFromStreak(int streakDays) {
    // Cap at 100: 30+ days = full score
    final streakScore = (streakDays / 30.0).clamp(0.0, 1.0) * 100.0;
    _recalculate(streak: streakScore);
  }

  /// Update from game stress score (0–100, inverted: high stress = low score).
  void updateFromGameResult(double stressScore) {
    final gameScore = 100.0 - stressScore;
    _recalculate(game: gameScore);
  }

  /// Update from journal sentiment (-1.0 to 1.0 → 0–100).
  void updateFromSentiment(double sentiment) {
    final sentimentScore = ((sentiment + 1.0) / 2.0) * 100.0;
    _recalculate(sentiment: sentimentScore);
  }

  /// Manually set Hopi's mood (e.g., for testing or direct control).
  void setMood(HopiMood mood) {
    emit(HopiStateData(
      compositeScore: state.compositeScore,
      mood: mood,
    ));
  }

  /// Set a specific score directly (useful for testing / initial load).
  void setScore(double score) {
    emit(HopiStateData.fromScore(score.clamp(0.0, 100.0)));
  }

  /// Resets Hopi's mood to its initial state when a user logs out.
  void reset() {
    _moodLog = 55.0;
    _streak = 50.0;
    _sleep = 50.0;
    _activity = 50.0;
    _game = 50.0;
    _sentiment = 50.0;
    _hrv = 50.0;
    emit(HopiStateData.initial());
  }

  // ─── Internal ───

  // Stored individual scores (persist these later)
  double _moodLog = 55.0;
  double _streak = 50.0;
  double _sleep = 50.0;
  double _activity = 50.0;
  double _game = 50.0;
  double _sentiment = 50.0;
  double _hrv = 50.0;

  void _recalculate({
    double? moodLog,
    double? streak,
    double? sleep,
    double? activity,
    double? game,
    double? sentiment,
    double? hrv,
  }) {
    if (moodLog != null) _moodLog = moodLog;
    if (streak != null) _streak = streak;
    if (sleep != null) _sleep = sleep;
    if (activity != null) _activity = activity;
    if (game != null) _game = game;
    if (sentiment != null) _sentiment = sentiment;
    if (hrv != null) _hrv = hrv;

    final composite = (_moodLog * 0.30) +
        (_streak * 0.20) +
        (_sleep * 0.15) +
        (_activity * 0.10) +
        (_game * 0.10) +
        (_sentiment * 0.10) +
        (_hrv * 0.05);

    emit(HopiStateData.fromScore(composite.clamp(0.0, 100.0)));
  }
}
