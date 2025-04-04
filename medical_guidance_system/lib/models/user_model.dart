class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final List<MedicalCondition> conditions;
  final HealthMetrics healthMetrics;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.conditions,
    required this.healthMetrics,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      conditions:
          (json['conditions'] as List)
              .map((condition) => MedicalCondition.fromJson(condition))
              .toList(),
      healthMetrics: HealthMetrics.fromJson(json['healthMetrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'conditions': conditions.map((condition) => condition.toJson()).toList(),
      'healthMetrics': healthMetrics.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    double? height,
    double? weight,
    List<MedicalCondition>? conditions,
    HealthMetrics? healthMetrics,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      conditions: conditions ?? this.conditions,
      healthMetrics: healthMetrics ?? this.healthMetrics,
    );
  }
}

class MedicalCondition {
  final String name;
  final String description;
  final int severityLevel; // 1-5
  final List<String> limitations;

  MedicalCondition({
    required this.name,
    required this.description,
    required this.severityLevel,
    required this.limitations,
  });

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      name: json['name'],
      description: json['description'],
      severityLevel: json['severityLevel'],
      limitations: List<String>.from(json['limitations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'severityLevel': severityLevel,
      'limitations': limitations,
    };
  }
}

class HealthMetrics {
  final int restingHeartRate;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int respiratoryRate;
  final double bloodGlucose;

  HealthMetrics({
    required this.restingHeartRate,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.respiratoryRate,
    required this.bloodGlucose,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      restingHeartRate: json['restingHeartRate'],
      bloodPressureSystolic: json['bloodPressureSystolic'],
      bloodPressureDiastolic: json['bloodPressureDiastolic'],
      respiratoryRate: json['respiratoryRate'],
      bloodGlucose: json['bloodGlucose'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restingHeartRate': restingHeartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'respiratoryRate': respiratoryRate,
      'bloodGlucose': bloodGlucose,
    };
  }
}

class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final List<Exercise> exercises;
  final int restBetweenExercises; // in seconds
  final List<String> warnings;
  final List<String> suitableConditions;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
    required this.restBetweenExercises,
    required this.warnings,
    required this.suitableConditions,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      exercises:
          (json['exercises'] as List)
              .map((exercise) => Exercise.fromJson(exercise))
              .toList(),
      restBetweenExercises: json['restBetweenExercises'],
      warnings: List<String>.from(json['warnings']),
      suitableConditions: List<String>.from(json['suitableConditions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'restBetweenExercises': restBetweenExercises,
      'warnings': warnings,
      'suitableConditions': suitableConditions,
    };
  }
}

class Exercise {
  final String name;
  final String description;
  final String imageUrl;
  final int durationSeconds;
  final int sets;
  final int reps;
  final List<String> limitations;

  Exercise({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.durationSeconds,
    required this.sets,
    required this.reps,
    required this.limitations,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      durationSeconds: json['durationSeconds'],
      sets: json['sets'],
      reps: json['reps'],
      limitations: List<String>.from(json['limitations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'sets': sets,
      'reps': reps,
      'limitations': limitations,
    };
  }
}
