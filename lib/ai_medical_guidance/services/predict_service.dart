import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class PredictService {
  // Use correct host depending on environment
  // Android emulator -> http://10.0.2.2:5000
  // iOS simulator   -> http://127.0.0.1:5000
  // Real device     -> http://<your-computer-LAN-IP>:5000
  static const String _baseUrl = 'http://192.168.8.130:5000';

  static Future<Map<String, dynamic>?> getPrediction(
    UserProfile userProfile, {
    String? fitnessLevel,
  }) async {
    try {
      // Goal flags
      final int weightLossFlag =
          _goalIs(userProfile.personalGoal, const [
            'weight loss',
            'lose weight',
          ])
          ? 1
          : 0;
      final int muscleGainFlag =
          _goalIs(userProfile.personalGoal, const [
            'muscle gain',
            'gain muscle',
            'build muscle',
          ])
          ? 1
          : 0;
      final int maintainFlag =
          _goalIs(userProfile.personalGoal, const [
            'maintain weight',
            'maintain healthy weight',
            'maintenance',
          ])
          ? 1
          : 0;

      // Diabetes flags
      final bool normalDia = _hasNormalDiabetes(userProfile);
      final bool highDia = _hasHighDiabetes(userProfile);

      // Input object
      final Map<String, dynamic> input = {
        'age': userProfile.age,
        'height': userProfile.height / 100,
        'weight': userProfile.weight,
        'weight_loss': weightLossFlag,
        'muscle_gain': muscleGainFlag,
        'maintain_healthy_weight': maintainFlag,
        'normal_diabetes': normalDia ? 1 : 0,
        'high_diabetes': highDia ? 1 : 0,
        'liver_disease': userProfile.liverDisease ? 1 : 0,
        'chronic_kidney_disease': userProfile.ckd ? 1 : 0,
        'hypertension': userProfile.hypertension ? 1 : 0,
        'gender_male': userProfile.gender.toLowerCase() == 'male' ? 1 : 0,
      };

      // Use the provided fitness level or default to 'Intermediate'
      final String levelToUse = fitnessLevel ?? 'Intermediate';
      final Map<String, dynamic> bodyToSend = {
        'input': input,
        'level': levelToUse,
      };

      final uri = Uri.parse('$_baseUrl/predict');

      print('🏋️ Using fitness level: $levelToUse');
      print('API Request URL: $uri');
      print('Request body: ${jsonEncode(bodyToSend)}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode(bodyToSend),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic parsed = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};
        if (parsed is Map<String, dynamic>) return parsed;
        return {'data': parsed};
      }
      return null;
    } catch (e) {
      print('Error calling predict endpoint: $e');
      return null;
    }
  }

  // ---------- Helpers ----------
  static bool _goalIs(String goal, List<String> synonyms) {
    final g = goal.toLowerCase().trim();
    return synonyms.any((s) => g == s);
  }

  static bool _hasNormalDiabetes(UserProfile u) {
    if (!(u.diabetes == true)) return false;
    final type = u.diabetesType?.toLowerCase().trim();
    return type == 'prediabetes' || type == 'gestational';
  }

  static bool _hasHighDiabetes(UserProfile u) {
    if (!(u.diabetes == true)) return false;
    final type = u.diabetesType?.toLowerCase().trim();
    return type == 'type 1' || type == 'type 2';
  }
}
