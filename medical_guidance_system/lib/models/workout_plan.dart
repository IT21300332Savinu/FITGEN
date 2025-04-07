class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final String intensity; // 'low', 'moderate', 'high'
  final String type; // 'cardio', 'strength', 'flexibility', 'water', etc.
  final List<Exercise> exercises;
  final List<String>
  suitableConditions; // Health conditions this is suitable for
  final List<String> warnings; // Precautions for specific health conditions
  final int recommendedDurationMinutes;
  final int caloriesBurned; // Estimated calories burned
  final List<String>
  targetMuscleGroups; // Targeted muscle groups (e.g., 'Legs', 'Arms')
  final bool isRecommended; // Whether this workout is recommended for the user
  final List<String>
  tags; // Tags for categorization (e.g., 'Beginner', 'Weight Loss')

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
    required this.targetMuscleGroups,
    required this.isRecommended,
    required this.tags,
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
      targetMuscleGroups: List<String>.from(json['targetMuscleGroups'] ?? []),
      isRecommended: json['isRecommended'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
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
      'targetMuscleGroups': targetMuscleGroups,
      'isRecommended': isRecommended,
      'tags': tags,
    };
  }
}

class Exercise {
  final String name;
  final String description;
  final String? imageUrl;
  final String? videoUrl; // URL for exercise demonstration video
  final String equipment; // Equipment required (e.g., 'Dumbbells', 'None')
  final String difficultyLevel; // 'Beginner', 'Intermediate', 'Advanced'
  final int sets;
  final int reps;
  final int restSeconds;
  final List<String>
  modifications; // Modifications for different health conditions

  Exercise({
    required this.name,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    required this.equipment,
    required this.difficultyLevel,
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
      videoUrl: json['videoUrl'],
      equipment: json['equipment'] ?? 'None',
      difficultyLevel: json['difficultyLevel'] ?? 'Beginner',
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
      'videoUrl': videoUrl,
      'equipment': equipment,
      'difficultyLevel': difficultyLevel,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'modifications': modifications,
    };
  }
}
