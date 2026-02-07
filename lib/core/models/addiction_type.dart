enum AddictionType {
  opiates('OPIATES'),
  cocaine('COCAINE'),
  alcohol('ALCOHOL'),
  other('OTHER');
  
  final String value;
  const AddictionType(this.value);
  
  static AddictionType fromString(String value) {
    return AddictionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AddictionType.other,
    );
  }
  
  String get displayName {
    switch (this) {
      case AddictionType.opiates:
        return 'Opiates';
      case AddictionType.cocaine:
        return 'Cocaine';
      case AddictionType.alcohol:
        return 'Alcohol';
      case AddictionType.other:
        return 'Other';
    }
  }
}
