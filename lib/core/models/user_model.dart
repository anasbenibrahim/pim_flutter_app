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
  // Patient information for family members
  final int? patientId;
  final String? patientNom;
  final String? patientPrenom;
  
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
    this.patientId,
    this.patientNom,
    this.patientPrenom,
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
      patientId: json['patientId'] as int?,
      patientNom: json['patientNom'] as String?,
      patientPrenom: json['patientPrenom'] as String?,
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
      'patientId': patientId,
      'patientNom': patientNom,
      'patientPrenom': patientPrenom,
    };
  }
}
