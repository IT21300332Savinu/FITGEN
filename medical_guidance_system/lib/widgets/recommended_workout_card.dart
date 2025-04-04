import 'package:flutter/material.dart';
import '../models/workout_plan.dart';
import '../widgets/recommended_workout_card.dart';

class RecommendedWorkoutCard extends StatelessWidget {
  final WorkoutPlan workout;
  final VoidCallback onTap;

  const RecommendedWorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout name
              Text(
                workout.name.isNotEmpty ? workout.name : 'Unnamed Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Workout description
              Text(
                workout.description.isNotEmpty
                    ? workout.description
                    : 'No description available',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
