import 'package:flutter/material.dart';
import '../screens/workout_recommendations_screen.dart';
import '../models/user_profile.dart';

class NavigationService {
  static void navigateToWorkoutRecommendations(
    BuildContext context, {
    required UserProfile userProfile,
    String? selectedLevel,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutRecommendationsScreen(
          userProfile: userProfile,
          selectedLevel: selectedLevel,
        ),
      ),
    );
  }
}

// Example usage in other screens:
// NavigationService.navigateToWorkoutRecommendations(
//   context,
//   userProfile: currentUserProfile,
//   selectedLevel: 'Intermediate',
// );
