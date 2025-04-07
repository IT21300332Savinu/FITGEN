import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class WorkoutRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get workout recommendations based on user health conditions
  Future<List<WorkoutPlan>> getRecommendedWorkouts(UserModel user) async {
    try {
      // Determine the relevant health conditions
      List<String> healthConditions = [];

      // Check for diabetes
      if (user.healthMetrics.bloodGlucose > 7.0) {
        healthConditions.add('hyperglycemia');
      } else if (user.healthMetrics.bloodGlucose < 3.9) {
        healthConditions.add('hypoglycemia');
      }

      // Check for hypertension
      if (user.healthMetrics.bloodPressureSystolic >= 140 ||
          user.healthMetrics.bloodPressureDiastolic >= 90) {
        healthConditions.add('hypertension');
      }

      // Add conditions from user profile
      for (var condition in user.conditions) {
        String normalizedCondition = condition.name.toLowerCase().replaceAll(
          ' ',
          '_',
        );
        healthConditions.add(normalizedCondition);
      }

      // If no specific conditions, use 'general' tag
      if (healthConditions.isEmpty) {
        healthConditions.add('general');
      }

      // Fetch workouts from Firestore
      QuerySnapshot snapshot =
          await _firestore
              .collection('workouts')
              .where('suitableConditions', arrayContainsAny: healthConditions)
              .get();

      if (snapshot.docs.isEmpty) {
        // Fallback to general workouts if no specific ones found
        snapshot =
            await _firestore
                .collection('workouts')
                .where('suitableConditions', arrayContains: 'general')
                .get();
      }

      // Convert to workout objects
      List<WorkoutPlan> workouts =
          snapshot.docs
              .map(
                (doc) =>
                    WorkoutPlan.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      // Score and sort workouts based on relevance to user's conditions
      workouts.sort((a, b) {
        int aScore = _calculateWorkoutScore(a, user, healthConditions);
        int bScore = _calculateWorkoutScore(b, user, healthConditions);
        return bScore.compareTo(aScore); // Higher score first
      });

      return workouts;
    } catch (e) {
      print('Error getting workout recommendations: $e');
      return [];
    }
  }

  // Calculate how well a workout matches the user's health needs
  int _calculateWorkoutScore(
    WorkoutPlan workout,
    UserModel user,
    List<String> userConditions,
  ) {
    int score = 0;

    // Higher score for workouts that match more of the user's conditions
    for (var condition in userConditions) {
      if (workout.suitableConditions.contains(condition)) {
        score += 10;
      }
    }

    // Adjust score based on workout intensity vs user health
    if (user.healthMetrics.bloodPressureSystolic >= 160 ||
        user.healthMetrics.bloodPressureDiastolic >= 100) {
      // For severe hypertension, lower-intensity workouts score higher
      if (workout.intensity == 'low') score += 15;
      if (workout.intensity == 'moderate') score += 5;
      if (workout.intensity == 'high') score -= 10;
    }

    // For blood glucose management
    if (userConditions.contains('hyperglycemia')) {
      // Moderate intensity often better for high blood glucose
      if (workout.intensity == 'low') score += 5;
      if (workout.intensity == 'moderate') score += 10;
    } else if (userConditions.contains('hypoglycemia')) {
      // Low intensity better for low blood glucose to prevent further drops
      if (workout.intensity == 'low') score += 15;
      if (workout.intensity == 'moderate') score -= 5;
      if (workout.intensity == 'high') score -= 15;
    }

    // Consider user's BMI
    if (user.bmi >= 30) {
      // Obese
      if (workout.intensity == 'low') score += 10;
      if (workout.type == 'water')
        score += 10; // Water exercises better for joints
    }

    return score;
  }

  // Generate specific exercise modifications based on health conditions
  List<String> generateExerciseModifications(
    WorkoutPlan workout,
    UserModel user,
  ) {
    List<String> modifications = [];

    // Diabetes modifications
    if (user.healthMetrics.bloodGlucose > 7.0) {
      modifications.add(
        'Monitor blood glucose before, during, and after workout',
      );
      modifications.add('Have a fast-acting carbohydrate source available');
      modifications.add('Stay well hydrated throughout the workout');
    }

    // Hypertension modifications
    if (user.healthMetrics.bloodPressureSystolic >= 140 ||
        user.healthMetrics.bloodPressureDiastolic >= 90) {
      modifications.add('Avoid holding breath during exercises');
      modifications.add('Take more frequent rest periods');
      modifications.add('Reduce intensity if feeling lightheaded or dizzy');
    }

    // CKD modifications
    if (user.conditions.any((c) => c.name == 'Chronic Kidney Disease')) {
      modifications.add('Focus on lower intensity exercises');
      modifications.add(
        'Stay well hydrated but consult doctor about fluid intake limits',
      );
      modifications.add('Avoid exercises that could risk falls or impacts');
    }

    // Fatty liver modifications
    if (user.conditions.any((c) => c.name == 'Fatty Liver')) {
      modifications.add('Focus on consistent moderate activity');
      modifications.add('Combine cardio with resistance training');
      modifications.add('Aim for at least 150 minutes of exercise per week');
    }

    return modifications;
  }

  // Track workout completion and adjust recommendations accordingly
  Future<void> trackWorkoutCompletion(
    String userId,
    String workoutId,
    double completionPercentage,
    Map<String, dynamic> healthMetricsAfter,
  ) async {
    try {
      // Save workout record
      await _firestore.collection('workout_history').add({
        'userId': userId,
        'workoutId': workoutId,
        'completionPercentage': completionPercentage,
        'timestamp': FieldValue.serverTimestamp(),
        'healthMetricsAfter': healthMetricsAfter,
      });

      // You could add logic here to update user's workout preferences
      // based on their completion history
    } catch (e) {
      print('Error tracking workout completion: $e');
    }
  }
}

// This class represents the workout plan structure that would be stored in Firestore
class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final String intensity; // 'low', 'moderate', 'high'
  final String type; // 'cardio', 'strength', 'flexibility', 'water', etc.
  final List<Exercise> exercises;
  final List<String>
  suitableConditions; // health conditions this is suitable for
  final List<String> warnings; // precautions for specific health conditions
  final int recommendedDurationMinutes;
  final int caloriesBurned; // estimated calories burned

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.intensity,
    required this.type,
    required this.exercises,
    required this.suitableConditions,
    required this.warnings,
    required this.recommendedDurationMinutes,
    required this.caloriesBurned,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    var exercisesList =
        (json['exercises'] as List?)
            ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkoutPlan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      intensity: json['intensity'] ?? 'moderate',
      type: json['type'] ?? 'general',
      exercises: exercisesList,
      suitableConditions: List<String>.from(json['suitableConditions'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      recommendedDurationMinutes: json['recommendedDurationMinutes'] ?? 30,
      caloriesBurned: json['caloriesBurned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'intensity': intensity,
      'type': type,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'suitableConditions': suitableConditions,
      'warnings': warnings,
      'recommendedDurationMinutes': recommendedDurationMinutes,
      'caloriesBurned': caloriesBurned,
    };
  }
}

class Exercise {
  final String name;
  final String description;
  final String? imageUrl;
  final int sets;
  final int reps;
  final int restSeconds;
  final List<String>
  modifications; // modifications for different health conditions

  Exercise({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.modifications,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      sets: json['sets'] ?? 1,
      reps: json['reps'] ?? 10,
      restSeconds: json['restSeconds'] ?? 60,
      modifications: List<String>.from(json['modifications'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'modifications': modifications,
    };
  }
}
