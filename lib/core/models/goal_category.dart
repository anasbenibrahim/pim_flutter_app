enum GoalCategory {
  timeBased,
  reductionBased,
  alternativeBehavior;

  static GoalCategory fromString(String value) {
    final v = value.toUpperCase().replaceAll('_', '');
    if (v.contains('TIMEBASED')) return GoalCategory.timeBased;
    if (v.contains('REDUCTION')) return GoalCategory.reductionBased;
    if (v.contains('ALTERNATIVE')) return GoalCategory.alternativeBehavior;
    return GoalCategory.timeBased;
  }

  String get displayName {
    switch (this) {
      case GoalCategory.timeBased:
        return 'Time-based';
      case GoalCategory.reductionBased:
        return 'Reduction';
      case GoalCategory.alternativeBehavior:
        return 'Alternative';
    }
  }

  /// API value: TIME_BASED, REDUCTION_BASED, ALTERNATIVE_BEHAVIOR
  String get apiValue {
    switch (this) {
      case GoalCategory.timeBased:
        return 'TIME_BASED';
      case GoalCategory.reductionBased:
        return 'REDUCTION_BASED';
      case GoalCategory.alternativeBehavior:
        return 'ALTERNATIVE_BEHAVIOR';
    }
  }
}
