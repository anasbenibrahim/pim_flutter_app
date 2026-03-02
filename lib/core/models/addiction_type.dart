enum AddictionType {
  cannabis('CANNABIS'),
  cocaine('COCAINE'),
  heroin('HEROIN'),
  ecstasy('ECSTASY'),
  prescriptionPills('PRESCRIPTION_PILLS'),
  syntheticDrugs('SYNTHETIC_DRUGS'),
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
      case AddictionType.cannabis:
        return 'Cannabis';
      case AddictionType.cocaine:
        return 'Cocaine';
      case AddictionType.heroin:
        return 'Heroin';
      case AddictionType.ecstasy:
        return 'Ecstasy';
      case AddictionType.prescriptionPills:
        return 'Prescription Pills';
      case AddictionType.syntheticDrugs:
        return 'Synthetic Drugs';
      case AddictionType.other:
        return 'Other';
    }
  }
}
