import 'user_role.dart';

class UserModel {
  final int id;
  final String email;
  final String nom;
  final String prenom;
  final int? age;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final String? referralCode; // Only for patients
  final bool hasCompletedOnboarding;
  final int profileCompletionScore;
  final bool hasCompletedAssessment;
  // Patient information for family members
  final int? patientId;
  final String? patientNom;
  final String? patientPrenom;
  final String? addiction;
  final DateTime? sobrietyDate;
  
  UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.age,
    required this.role,
    this.profileImageUrl,
    this.createdAt,
    this.referralCode,
    this.hasCompletedOnboarding = false,
    this.profileCompletionScore = 0,
    this.hasCompletedAssessment = false,
    this.patientId,
    this.patientNom,
    this.patientPrenom,
    this.addiction,
    this.sobrietyDate,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      age: json['age'] as int?,
      role: UserRole.fromString(json['role'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      referralCode: json['referralCode'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      profileCompletionScore: json['profileCompletionScore'] as int? ?? 0,
      hasCompletedAssessment: json['hasCompletedAssessment'] as bool? ?? false,
      patientId: json['patientId'] as int?,
      patientNom: json['patientNom'] as String?,
      patientPrenom: json['patientPrenom'] as String?,
      addiction: json['addiction'] as String?,
      sobrietyDate: json['sobrietyDate'] != null 
          ? DateTime.parse(json['sobrietyDate'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'age': age,
      'role': role.value,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'referralCode': referralCode,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'profileCompletionScore': profileCompletionScore,
      'hasCompletedAssessment': hasCompletedAssessment,
      'patientId': patientId,
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
      'addiction': addiction,
      'sobrietyDate': sobrietyDate?.toIso8601String(),
    };
  }
}
