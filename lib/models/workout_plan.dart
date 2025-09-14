class WorkoutExercise {
  final String day;
  final String level;
  final String exercise;

  WorkoutExercise({
    required this.day,
    required this.level,
    required this.exercise,
  });

  factory WorkoutExercise.fromCsv(List<String> row) {
    return WorkoutExercise(day: row[0], level: row[1], exercise: row[2]);
  }
}

class WorkoutPlan {
  final String fitnessType;
  final String level;
  final List<WorkoutExercise> exercises;

  WorkoutPlan({
    required this.fitnessType,
    required this.level,
    required this.exercises,
  });
}

class FitnessPrediction {
  final String label;
  final double confidence;

  FitnessPrediction({required this.label, required this.confidence});
}
