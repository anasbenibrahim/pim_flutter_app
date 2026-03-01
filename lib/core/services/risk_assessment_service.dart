import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class RiskAssessmentService {
  // TODO: Update with your public Localtunnel / Ngrok URL
  static const String _webhookUrl = 'https://ghostily-dashy-palmira.ngrok-free.dev/webhook/hopeup-risk-check';

  Future<void> analyzeRisk({
    required UserModel user,
    required String? healthGoal,
    required String? gender,
    required int? moodLevel,
    required int? sleepQuality,
    required int? stressLevel,
    required bool? soughtHelp,
    required bool? takingMeds,
    required String? medications,
    required bool? physicalDistress,
    required List<String> symptoms,
    required List<String> personalityTraits,
    required List<String> mentalHealthConcerns,
  }) async {
    try {
      final body = {
        'patient_id': user.id,
        'user_name': '${user.prenom} ${user.nom}',
        'health_goal': healthGoal ?? 'Stay_on_track',
        'gender': gender ?? 'Other',
        'mood': moodLevel ?? 3,
        'sleep_quality': _mapSleep(sleepQuality),
        'stress': stressLevel ?? 3,
        'prof_help': soughtHelp == true ? 1 : 0,
        'meds': takingMeds == true ? 1 : 0,
        'symptoms': symptoms,
        'personality': personalityTraits,
        'mental_health': mentalHealthConcerns,
        'addiction_type': ['Other'], // Should be fetched from patient profile
        'days_in_recovery': 30, // Should be fetched from patient profile
      };

      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print('Error triggering risk assessment: ${response.body}');
      }
    } catch (e) {
      print('RiskAssessmentService error: $e');
    }
  }

  String _mapSleep(int? level) {
    if (level == null) return 'Fair';
    if (level <= 1) return 'Worst';
    if (level == 2) return 'Poor';
    if (level == 3) return 'Fair';
    if (level == 4) return 'Good';
    return 'Excellent';
  }
}
