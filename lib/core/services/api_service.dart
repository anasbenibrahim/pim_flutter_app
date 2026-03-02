import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../models/objectif_model.dart';
import '../models/weekly_achievement_model.dart';
import '../models/achievement_badge.dart';
import '../models/goal_model.dart';
import '../models/goal_category.dart';
import '../models/goal_difficulty.dart';
import '../models/gamification_model.dart';

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
      };
      
      // Add JSON data as a field
      request.fields['data'] = jsonEncode(jsonData);
      
      // Add image if provided
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Connection timeout. Is the backend running at ${ApiConstants.baseUrl}?'),
      );
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
        final String message = _parseErrorMessage(response.body, 'Registration failed');
        throw Exception(message);
      }
    } on TimeoutException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') || msg.contains('Failed host lookup') || msg.contains('SocketException')) {
        throw Exception('Cannot reach server. Ensure Spring backend is running (mvn spring-boot:run) and try again.');
      }
      throw Exception('Registration failed: $msg');
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
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Connection timeout. Is the backend running at ${ApiConstants.baseUrl}?'),
      );
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
        final String message = _parseErrorMessage(response.body, 'Registration failed');
        throw Exception(message);
      }
    } on TimeoutException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') || msg.contains('Failed host lookup') || msg.contains('SocketException')) {
        throw Exception('Cannot reach server. Ensure Spring backend is running (mvn spring-boot:run) and try again.');
      }
      throw Exception('Registration failed: $msg');
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
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Connection timeout. Is the backend running at ${ApiConstants.baseUrl}?'),
      );
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
        final String message = _parseErrorMessage(response.body, 'Registration failed');
        throw Exception(message);
      }
    } on TimeoutException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Connection refused') || msg.contains('Failed host lookup') || msg.contains('SocketException')) {
        throw Exception('Cannot reach server. Ensure Spring backend is running (mvn spring-boot:run) and try again.');
      }
      throw Exception('Registration failed: $msg');
    }
  }
  
  /// Parse error message from API response body
  String _parseErrorMessage(String body, String fallback) {
    if (body.isEmpty) return fallback;
    try {
      final error = jsonDecode(body) as Map<String, dynamic>;
      return error['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
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
  }) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');

    print('DEBUG: Request URL: ${ApiConstants.baseUrl}${ApiConstants.completeOnboarding}');
    print('DEBUG: Request Body: ${jsonEncode({
      'sobrietyDate': sobrietyDate?.toIso8601String().split('T')[0],
      'addiction': substance,
      'lifeRhythm': lifeRhythm,
      'activityStatus': activityStatus,
      'region': region,
      'triggers': triggers,
      'copingMechanisms': copingMechanisms,
      'motivations': motivations,
    })}');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeOnboarding}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'sobrietyDate': sobrietyDate?.toIso8601String().split('T')[0],
        'addiction': substance,
        'lifeRhythm': lifeRhythm,
        'activityStatus': activityStatus,
        'region': region,
        'triggers': triggers,
        'copingMechanisms': copingMechanisms,
        'motivations': motivations,
      }),
    );

    print('DEBUG: Response Status Code: ${response.statusCode}');
    print('DEBUG: Response Body: ${response.body}');

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

  // Goals API (addiction reduction)
  Future<List<GoalModel>> getGoals() async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goals}'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list.map((e) => GoalModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to load goals');
    } catch (e) {
      throw Exception('Failed to load goals: ${e.toString()}');
    }
  }

  Future<GoalModel> createGoal({
    required GoalCategory category,
    required String title,
    required GoalDifficulty difficulty,
    required int targetValue,
    String? targetUnit,
    int? initialValue,
  }) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final body = {
        'category': category.apiValue,
        'title': title,
        'difficulty': difficulty.apiValue,
        'targetValue': targetValue,
        if (targetUnit != null) 'targetUnit': targetUnit,
        if (initialValue != null) 'initialValue': initialValue,
      };
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goals}'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 201) {
        return GoalModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to create goal');
    } catch (e) {
      throw Exception('Failed to create goal: ${e.toString()}');
    }
  }

  Future<GoalModel> getGoal(int id) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goals}/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return GoalModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to load goal');
    } catch (e) {
      throw Exception('Failed to load goal: ${e.toString()}');
    }
  }

  Future<GoalModel> addGoalCheckIn(int goalId, {DateTime? date}) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final dateStr = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goals}/$goalId/check-in$dateStr'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return GoalModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to add check-in');
    } catch (e) {
      throw Exception('Failed to add check-in: ${e.toString()}');
    }
  }

  Future<GamificationModel> validateGoal(int goalId, {String? note}) async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goals}/$goalId/validate'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'note': note ?? ''}),
      );
      if (response.statusCode == 200) {
        return GamificationModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to validate goal');
    } catch (e) {
      throw Exception('Failed to validate goal: ${e.toString()}');
    }
  }

  Future<GamificationModel> getGamification() async {
    await _loadTokens();
    if (_accessToken == null) throw Exception('Not authenticated');
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.goalsGamification}'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return GamificationModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(err['message'] ?? 'Failed to load gamification');
    } catch (e) {
      throw Exception('Failed to load gamification: ${e.toString()}');
    }
  }

  // Stubs for objectifs/badges features (not yet in backend)
  Future<List<ObjectifModel>> getObjectifs() async => [];
  Future<void> createObjectif({required DateTime objectifDate, required dynamic mood, required bool consumed, String? notes}) async {}
  Future<void> deleteObjectif(int id) async {}
  Future<WeeklyAchievementModel> getWeeklyAchievement({required String weekStart}) async {
    final start = DateTime.parse(weekStart);
    final end = start.add(const Duration(days: 6));
    return WeeklyAchievementModel(
      badge: AchievementBadge.champion,
      badgeLabel: 'Champion',
      badgeDescription: 'No data yet',
      weekStart: start,
      weekEnd: end,
      abstinentDays: 0,
      consumedDays: 0,
      totalDaysWithData: 0,
    );
  }
}
