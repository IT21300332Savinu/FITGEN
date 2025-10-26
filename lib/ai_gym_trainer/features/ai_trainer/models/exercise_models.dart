enum ExerciseCategory { weightLoss, weightGain, maintainHealth }

enum ExerciseType { bicepCurl, pushup, squat, armCircling, shoulderPress }

class ExerciseDefinition {
  final ExerciseType type;
  final String name;
  final String description;
  final ExerciseCategory category;
  final List<String> targetMuscles;
  final int estimatedCaloriesPerRep;
  final String difficulty;
  final Duration estimatedDuration;
  final String instructions;

  const ExerciseDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    required this.targetMuscles,
    required this.estimatedCaloriesPerRep,
    required this.difficulty,
    required this.estimatedDuration,
    required this.instructions,
  });
}

class ExerciseDatabase {
  static const Map<ExerciseType, ExerciseDefinition> exercises = {
    ExerciseType.bicepCurl: ExerciseDefinition(
      type: ExerciseType.bicepCurl,
      name: 'Bicep Curl',
      description: 'Strengthen your biceps with controlled arm movements',
      category: ExerciseCategory.weightGain,
      targetMuscles: ['Biceps', 'Forearms'],
      estimatedCaloriesPerRep: 2,
      difficulty: 'Beginner',
      estimatedDuration: Duration(minutes: 5),
      instructions: 'Keep your upper arms stationary and curl the weights up',
    ),

    ExerciseType.pushup: ExerciseDefinition(
      type: ExerciseType.pushup,
      name: 'Push-up',
      description: 'Full body exercise targeting chest, arms, and core',
      category: ExerciseCategory.weightLoss,
      targetMuscles: ['Chest', 'Triceps', 'Shoulders', 'Core'],
      estimatedCaloriesPerRep: 4,
      difficulty: 'Intermediate',
      estimatedDuration: Duration(minutes: 8),
      instructions: 'Lower your body until chest nearly touches the ground',
    ),

    ExerciseType.squat: ExerciseDefinition(
      type: ExerciseType.squat,
      name: 'Squat',
      description: 'Lower body strengthening exercise for legs and glutes',
      category: ExerciseCategory.maintainHealth,
      targetMuscles: ['Quadriceps', 'Glutes', 'Hamstrings', 'Calves'],
      estimatedCaloriesPerRep: 5,
      difficulty: 'Beginner',
      estimatedDuration: Duration(minutes: 6),
      instructions: 'Lower your hips as if sitting back into a chair',
    ),

    ExerciseType.armCircling: ExerciseDefinition(
      type: ExerciseType.armCircling,
      name: 'Arm Circling',
      description: 'Dynamic shoulder mobility and warm-up exercise',
      category: ExerciseCategory.maintainHealth,
      targetMuscles: ['Shoulders', 'Arms'],
      estimatedCaloriesPerRep: 1,
      difficulty: 'Beginner',
      estimatedDuration: Duration(minutes: 3),
      instructions: 'Make large circles with your arms in a controlled motion',
    ),

    ExerciseType.shoulderPress: ExerciseDefinition(
      type: ExerciseType.shoulderPress,
      name: 'Shoulder Press',
      description: 'Overhead pressing movement for shoulder strength',
      category: ExerciseCategory.weightGain,
      targetMuscles: ['Shoulders', 'Triceps', 'Upper chest'],
      estimatedCaloriesPerRep: 3,
      difficulty: 'Intermediate',
      estimatedDuration: Duration(minutes: 7),
      instructions: 'Press weights overhead while keeping core tight',
    ),
  };

  static List<ExerciseDefinition> getExercisesByCategory(
    ExerciseCategory category,
  ) {
    return exercises.values
        .where((exercise) => exercise.category == category)
        .toList();
  }

  static ExerciseDefinition? getExercise(ExerciseType type) {
    return exercises[type];
  }

  static String getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.weightLoss:
        return 'Weight Loss';
      case ExerciseCategory.weightGain:
        return 'Weight Gain';
      case ExerciseCategory.maintainHealth:
        return 'Maintain Health';
    }
  }

  static String getCategoryDescription(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.weightLoss:
        return 'High-intensity exercises to burn calories and lose weight';
      case ExerciseCategory.weightGain:
        return 'Strength training exercises to build muscle mass';
      case ExerciseCategory.maintainHealth:
        return 'Balanced exercises for overall health and mobility';
    }
  }
}
