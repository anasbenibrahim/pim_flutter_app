import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  String? _accessToken;
  String? _refreshToken;
  
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }
  
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _accessToken = null;
    _refreshToken = null;
  }
  
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        return authResponse;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<AuthResponse> registerPatient({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required int age,
    required DateTime dateNaissance,
    DateTime? sobrietyDate,
    String? addiction,
    String? imagePath,
    String? username,
    bool prenamePrivate = false,
    String? usageDuration,
    List<String> hobbies = const [],
    List<String> triggers = const [],
    List<String> copingMechanisms = const [],
    List<String> motivations = const [],
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerPatient}'),
      );
      
      // Add JSON data as a part with proper content type
      final jsonData = {
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'age': age,
        'dateNaissance': dateNaissance.toIso8601String().split('T')[0],
        'sobrietyDate': sobrietyDate?.toIso8601String().split('T')[0],
        'addiction': addiction,
        'username': username,
        'prenamePrivate': prenamePrivate,
        'usageDuration': usageDuration,
        'hobbies': hobbies,
        'triggers': triggers,
        'copingMechanisms': copingMechanisms,
        'motivations': motivations,
      };
      
      // Add JSON data as a field
      request.fields['data'] = jsonEncode(jsonData);
      
      // Add image if provided
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // OTP sent successfully
        return AuthResponse(
          accessToken: '',
          refreshToken: '',
          email: email,
          role: UserRole.patient,
          userId: 0,
          message: 'OTP sent',
        );
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  Future<AuthResponse> registerVolontaire({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required int age,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerVolontaire}'),
      );
      
      final jsonData = {
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'age': age,
      };
      
      // Add JSON data as a field
      request.fields['data'] = jsonEncode(jsonData);
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // OTP sent successfully
        return AuthResponse(
          accessToken: '',
          refreshToken: '',
          email: email,
          role: UserRole.volontaire,
          userId: 0,
          message: 'OTP sent',
        );
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  Future<AuthResponse> registerFamilyMember({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String referralKey,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerFamily}'),
      );
      
      final jsonData = {
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'referralKey': referralKey,
      };
      
      // Add JSON data as a field
      request.fields['data'] = jsonEncode(jsonData);
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        // OTP sent successfully
        return AuthResponse(
          accessToken: '',
          refreshToken: '',
          email: email,
          role: UserRole.familyMember,
          userId: 0,
          message: 'OTP sent',
        );
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  Future<AuthResponse> verifyRegistrationOtp({
    required String email,
    required String otpCode,
    required String userRole,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyRegistrationOtp}'),
      );
      
      request.fields['email'] = email;
      request.fields['otpCode'] = otpCode;
      request.fields['userRole'] = userRole;
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        return authResponse;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }
  
  Future<UserModel> getCurrentUser() async {
    await _loadTokens();
    
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCurrentUser}'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to get user');
      }
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }
  
  Future<AuthResponse> refreshToken() async {
    await _loadTokens();
    
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshToken}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        await _saveTokens(authResponse.accessToken, authResponse.refreshToken);
        return authResponse;
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forgotPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }
  
  Future<void> verifyOtp(String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
      );
      
      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Invalid OTP code');
      }
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }
  
  Future<void> resetPassword(String email, String otpCode, String newPassword, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.resetPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        return;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  Future<UserModel> updatePatientProfile({
    required String nom,
    required String prenom,
    required int age,
    String? imagePath,
  }) async {
    await _loadTokens();
    
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updatePatientProfile}'),
      );
      
      request.headers['Authorization'] = 'Bearer $_accessToken';
      
      final jsonData = {
        'nom': nom,
        'prenom': prenom,
        'age': age,
      };
      
      request.fields['data'] = jsonEncode(jsonData);
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
  
  Future<UserModel> updateVolontaireProfile({
    required String nom,
    required String prenom,
    required int age,
    String? imagePath,
  }) async {
    await _loadTokens();
    
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateVolontaireProfile}'),
      );
      
      request.headers['Authorization'] = 'Bearer $_accessToken';
      
      final jsonData = {
        'nom': nom,
        'prenom': prenom,
        'age': age,
      };
      
      request.fields['data'] = jsonEncode(jsonData);
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
  
  Future<UserModel> updateFamilyMemberProfile({
    required String nom,
    required String prenom,
    String? imagePath,
  }) async {
    await _loadTokens();
    
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateFamilyMemberProfile}'),
      );
      
      request.headers['Authorization'] = 'Bearer $_accessToken';
      
      final jsonData = {
        'nom': nom,
        'prenom': prenom,
      };
      
      request.fields['data'] = jsonEncode(jsonData);
      
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  Future<void> completeOnboarding({
    required DateTime? sobrietyDate,
    required String? substance,
    required String? lifeRhythm,
    required String? activityStatus,
    required String? region,
    List<String>? triggers,
    List<String>? copingMechanisms,
    List<String>? motivations,
    String? username,
    bool? prenamePrivate,
    String? usageDuration,
    List<String>? hobbies,
  }) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');

    final body = {
      'sobrietyDate': sobrietyDate?.toIso8601String().split('T')[0],
      'addiction': substance,
      'lifeRhythm': lifeRhythm,
      'activityStatus': activityStatus,
      'region': region,
      'triggers': triggers,
      'copingMechanisms': copingMechanisms,
      'motivations': motivations,
      'username': username,
      'prenamePrivate': prenamePrivate,
      'usageDuration': usageDuration,
      'hobbies': hobbies,
    };

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeOnboarding}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to complete onboarding');
    }
  }

  Future<void> submitAssessment({
    String? gender,
    String? healthGoal,
    int? moodLevel,
    int? sleepQuality,
    int? stressLevel,
    bool? soughtProfessionalHelp,
    bool? takingMedications,
    String? medications,
    bool? physicalDistress,
    List<String>? symptoms,
    List<String>? personalityTraits,
    List<String>? mentalHealthConcerns,
  }) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeAssessment}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'gender': gender,
        'healthGoal': healthGoal,
        'moodLevel': moodLevel,
        'sleepQuality': sleepQuality,
        'stressLevel': stressLevel,
        'soughtProfessionalHelp': soughtProfessionalHelp,
        'takingMedications': takingMedications,
        'medications': medications,
        'physicalDistress': physicalDistress,
        'symptoms': symptoms,
        'personalityTraits': personalityTraits,
        'mentalHealthConcerns': mentalHealthConcerns,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Failed to submit assessment';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {
        // Backend might return HTML error page instead of JSON
        message = 'An unexpected error occurred: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}';
      }
      throw Exception(message);
    }
  }

  Future<void> saveGameLog({
    required String gameType,
    required List<int> rawData,
    required String derivedState,
  }) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gameLogs}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'gameType': gameType,
        'rawData': rawData,
        'derivedState': derivedState,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Failed to save game log';
      try {
        final error = jsonDecode(response.body);
        message = error['message'] ?? message;
      } catch (_) {
        message = 'An error occurred: ${response.body}';
      }
      throw Exception(message);
    }
  }
}
