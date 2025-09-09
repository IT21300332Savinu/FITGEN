import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/workout_plan.dart';

class WorkoutService {
  static Future<WorkoutPlan> loadWorkoutPlan(
    String fitnessType,
    String level,
  ) async {
    try {
      final fileName = '${fitnessType.replaceAll(' ', '_')}_$level.csv';
      final csvData = await rootBundle.loadString(
        'assets/data/workouts/$fileName',
      );

      List<List<dynamic>> csvTable = const CsvToListConverter().convert(
        csvData,
      );

      // Skip header row
      final exercises = csvTable.skip(1).map((row) {
        return WorkoutExercise.fromCsv(row.map((e) => e.toString()).toList());
      }).toList();

      return WorkoutPlan(
        fitnessType: fitnessType,
        level: level,
        exercises: exercises,
      );
    } catch (e) {
      print('Error loading workout plan: $e');
      throw Exception(
        'Failed to load workout plan for $fitnessType ($level): $e',
      );
    }
  }

  static Future<List<WorkoutPlan>> loadMultipleWorkoutPlans(
    List<String> fitnessTypes,
    String level,
  ) async {
    final workoutPlans = <WorkoutPlan>[];

    for (final fitnessType in fitnessTypes) {
      try {
        final plan = await loadWorkoutPlan(fitnessType, level);
        workoutPlans.add(plan);
      } catch (e) {
        print('Warning: Could not load plan for $fitnessType: $e');
      }
    }

    return workoutPlans;
  }
}
