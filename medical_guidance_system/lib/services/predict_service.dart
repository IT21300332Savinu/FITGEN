import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class PredictService {
  static const String _baseUrl = 'https://b22a11c6f901.ngrok-free.app';

  /// Calls the /predict endpoint with user profile data.
  /// Returns decoded JSON response or null on error.
  static Future<Map<String, dynamic>?> getPrediction(
    UserProfile userProfile,
  ) async {
    try {
      // Prepare the request body to match your Flask API expectations
      final requestBody = {
        'age': userProfile.age.toDouble(),
        'gender': userProfile.gender.toLowerCase(),
        'height': userProfile.height / 100, // Convert cm to meters
        'weight': userProfile.weight.toDouble(),
        'goal': _mapGoalToNumber(userProfile.personalGoal),
        'normal_diabetes': _hasNormalDiabetes(userProfile),
        'high_diabetes': _hasHighDiabetes(userProfile),
        'liver_disease': userProfile.liverDisease,
        'chronic_kidney_disease': userProfile.ckd,
        'hypertension': userProfile.hypertension,
      };

      print('API Request URL: $_baseUrl/predict');
      print('Request body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true', // Required for ngrok
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty ? json.decode(response.body) : {};
        if (body is Map<String, dynamic>) {
          return body;
        }
        return {"data": body};
      }

      return null;
    } catch (e) {
      print('Error calling predict endpoint: $e');
      return null;
    }
  }

  /// Maps user goal to number format expected by the backend
  static String _mapGoalToNumber(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight loss':
      case 'lose weight':
        return '1';
      case 'muscle gain':
      case 'gain muscle':
      case 'build muscle':
        return '2';
      case 'maintain weight':
      case 'maintain healthy weight':
      case 'maintenance':
        return '3';
      default:
        return '3'; // Default to maintenance
    }
  }

  /// Determines if user has normal diabetes
  static bool _hasNormalDiabetes(UserProfile userProfile) {
    if (!userProfile.diabetes) return false;
    return userProfile.diabetesType?.toLowerCase() == 'prediabetes' ||
        userProfile.diabetesType?.toLowerCase() == 'gestational';
  }

  /// Determines if user has high diabetes
  static bool _hasHighDiabetes(UserProfile userProfile) {
    if (!userProfile.diabetes) return false;
    return userProfile.diabetesType?.toLowerCase() == 'type 1' ||
        userProfile.diabetesType?.toLowerCase() == 'type 2';
  }

  /// Generic method for other API calls if needed
  static Future<Map<String, dynamic>?> getGenericPrediction({
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/predict',
      ).replace(queryParameters: queryParams?.map((k, v) => MapEntry(k, '$v')));

      final response = await http
          .get(
            uri,
            headers: {
              "Content-Type": "application/json",
              'ngrok-skip-browser-warning': 'true',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty ? json.decode(response.body) : {};
        if (body is Map<String, dynamic>) return body;
        return {"data": body};
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
