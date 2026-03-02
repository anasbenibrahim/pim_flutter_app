enum GoalStatus {
  inProgress,
  validated,
  failed,
  restart;

  static GoalStatus fromString(String value) {
    return GoalStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase().replaceAll('_', ''),
      orElse: () => GoalStatus.inProgress,
    );
  }

  String get displayName {
    switch (this) {
      case GoalStatus.inProgress:
        return 'In progress';
      case GoalStatus.validated:
        return 'Completed';
      case GoalStatus.failed:
        return 'Failed';
      case GoalStatus.restart:
        return 'Restart';
    }
  }
}
