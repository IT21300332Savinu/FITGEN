import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/user_profile.dart';
import '../models/workout_plan.dart';

class MLService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('models/fitgen.tflite');

      // Load labels
      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      _isInitialized = true;
      print('ML Service initialized successfully');
      print('Labels loaded: $_labels');
    } catch (e) {
      print('Error initializing ML Service: $e');
      throw Exception('Failed to initialize ML model: $e');
    }
  }

  static List<FitnessPrediction> predictFitnessTypes(UserProfile userProfile) {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('ML Service not initialized');
    }

    try {
      // Prepare input data (13 features as per your Python code)
      final inputData = _prepareInputData(userProfile);

      // Create input tensor
      final input = [inputData];
      final output = List.filled(
        1 * _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Process predictions
      final predictions = <FitnessPrediction>[];
      final probabilities = output[0] as List<double>;

      for (int i = 0; i < _labels.length; i++) {
        predictions.add(
          FitnessPrediction(label: _labels[i], confidence: probabilities[i]),
        );
      }

      // Sort by confidence
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return predictions;
    } catch (e) {
      print('Error during prediction: $e');
      throw Exception('Failed to predict fitness types: $e');
    }
  }

  static List<double> _prepareInputData(UserProfile userProfile) {
    // Calculate BMI
    final bmi = userProfile.weight / (userProfile.height * userProfile.height);

    return [
      userProfile.age.toDouble(),
      userProfile.height,
      userProfile.weight,
      userProfile.personalGoal == 'Weight Loss' ? 1.0 : 0.0,
      userProfile.personalGoal == 'Muscle Gain' ? 1.0 : 0.0,
      userProfile.personalGoal == 'Maintain Healthy Weight' ? 1.0 : 0.0,
      userProfile.medicalConditions.contains('Normal Diabetes') ? 1.0 : 0.0,
      userProfile.medicalConditions.contains('High Diabetes') ? 1.0 : 0.0,
      userProfile.medicalConditions.contains('Liver Disease') ? 1.0 : 0.0,
      userProfile.medicalConditions.contains('Chronic Kidney Disease')
          ? 1.0
          : 0.0,
      userProfile.medicalConditions.contains('Hypertension') ? 1.0 : 0.0,
      bmi,
      userProfile.gender == 'Male' ? 1.0 : 0.0,
    ];
  }

  static double _getDynamicThreshold(List<double> probabilities) {
    final sortedProbs = List<double>.from(probabilities)
      ..sort((a, b) => b.compareTo(a));

    if (sortedProbs[0] < 0.1) {
      return 0.05;
    }

    double largestGap = 0.0;
    double threshold = 0.15;

    for (int i = 0; i < sortedProbs.length - 1; i++) {
      final gap = sortedProbs[i] - sortedProbs[i + 1];
      if (gap > largestGap) {
        largestGap = gap;
        threshold = sortedProbs[i + 1];
      }
    }

    return (threshold + 0.01).clamp(0.05, 1.0);
  }

  static List<String> getRecommendedFitnessTypes(UserProfile userProfile) {
    final predictions = predictFitnessTypes(userProfile);
    final probabilities = predictions.map((p) => p.confidence).toList();
    final threshold = _getDynamicThreshold(probabilities);

    return predictions
        .where((prediction) => prediction.confidence >= threshold)
        .map((prediction) => prediction.label)
        .toList();
  }
}
