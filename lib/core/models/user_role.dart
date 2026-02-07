enum UserRole {
  patient('PATIENT'),
  volontaire('VOLONTAIRE'),
  familyMember('FAMILY_MEMBER');
  
  final String value;
  const UserRole(this.value);
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient,
    );
  }
  
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.volontaire:
        return 'Volontaire';
      case UserRole.familyMember:
        return 'Family Member';
    }
  }
}
