import 'user_role.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final UserRole role;
  final int userId;
  final String message;
  
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.role,
    required this.userId,
    required this.message,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      userId: json['userId'] as int,
      message: json['message'] as String? ?? 'Success',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'email': email,
      'role': role.value,
      'userId': userId,
      'message': message,
    };
  }
}
