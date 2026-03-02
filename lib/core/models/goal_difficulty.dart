enum GoalDifficulty {
  easy(10),
  medium(50),
  hard(100);

  final int xpReward;
  const GoalDifficulty(this.xpReward);

  static GoalDifficulty fromString(String value) {
    return GoalDifficulty.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => GoalDifficulty.easy,
    );
  }

  String get displayName {
    switch (this) {
      case GoalDifficulty.easy:
        return 'Easy';
      case GoalDifficulty.medium:
        return 'Medium';
      case GoalDifficulty.hard:
        return 'Hard';
    }
  }

  String get apiValue => name.toUpperCase();
}
