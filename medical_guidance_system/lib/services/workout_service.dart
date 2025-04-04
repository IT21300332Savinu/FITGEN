import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recommended workouts based on user conditions
  Future<List<WorkoutPlan>> getRecommendedWorkouts(UserModel user) async {
    try {
      // Get all workouts
      QuerySnapshot snapshot = await _firestore.collection('workouts').get();

      // Convert to WorkoutPlan objects
      List<WorkoutPlan> allWorkouts =
          snapshot.docs
              .map(
                (doc) =>
                    WorkoutPlan.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList();

      // Filter workouts suitable for user's conditions
      List<String> userConditionNames =
          user.conditions.map((c) => c.name).toList();

      if (userConditionNames.isEmpty) {
        // If user has no conditions, return general workouts
        return allWorkouts
            .where((workout) => workout.suitableConditions.contains('general'))
            .toList();
      }

      // Filter workouts that are suitable for the user's conditions
      List<WorkoutPlan> recommendedWorkouts =
          allWorkouts.where((workout) {
            // Check if any of the user's conditions match the workout's suitable conditions
            return workout.suitableConditions.any(
              (condition) => userConditionNames.contains(condition),
            );
          }).toList();

      // Sort by relevance (how many of the user's conditions match)
      recommendedWorkouts.sort((a, b) {
        int aMatches =
            a.suitableConditions
                .where((condition) => userConditionNames.contains(condition))
                .length;

        int bMatches =
            b.suitableConditions
                .where((condition) => userConditionNames.contains(condition))
                .length;

        return bMatches.compareTo(aMatches); // Higher matches first
      });

      return recommendedWorkouts;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  // Get workout by ID
  Future<WorkoutPlan?> getWorkoutById(String workoutId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('workouts').doc(workoutId).get();

      if (doc.exists) {
        return WorkoutPlan.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Save user workout progress
  Future<void> saveWorkoutProgress(
    String userId,
    String workoutId,
    int completionPercentage,
  ) async {
    try {
      await _firestore.collection('workout_progress').add({
        'userId': userId,
        'workoutId': workoutId,
        'completionPercentage': completionPercentage,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
