// file: lib/models/workout_session.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String id;
  final String workoutType; // e.g., strength, cardio, flexibility
  final DateTime timestamp;
  final int durationMinutes;
  final List<ExerciseSet> exercises;
  final int caloriesBurned;
  final double averageHeartRate;
  final double averageFormScore;
  final Map<String, dynamic> formFeedback;
  final Map<String, dynamic> wearableData;

  WorkoutSession({
    this.id = '',
    required this.workoutType,
    required this.timestamp,
    required this.durationMinutes,
    required this.exercises,
    required this.caloriesBurned,
    required this.averageHeartRate,
    required this.averageFormScore,
    this.formFeedback = const {},
    this.wearableData = const {},
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] ?? '',
      workoutType: map['workoutType'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'],
      exercises:
          (map['exercises'] as List)
              .map((e) => ExerciseSet.fromMap(e as Map<String, dynamic>))
              .toList(),
      caloriesBurned: map['caloriesBurned'],
      averageHeartRate: map['averageHeartRate'].toDouble(),
      averageFormScore: map['averageFormScore'].toDouble(),
      formFeedback: Map<String, dynamic>.from(map['formFeedback'] ?? {}),
      wearableData: Map<String, dynamic>.from(map['wearableData'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutType': workoutType,
      'timestamp': Timestamp.fromDate(timestamp),
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'caloriesBurned': caloriesBurned,
      'averageHeartRate': averageHeartRate,
      'averageFormScore': averageFormScore,
      'formFeedback': formFeedback,
      'wearableData': wearableData,
    };
  }
}

class ExerciseSet {
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight; // in kg, null for bodyweight exercises
  final double formScore; // 0-100
  final List<String> formIssues;

  ExerciseSet({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
    required this.formScore,
    this.formIssues = const [],
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      exerciseName: map['exerciseName'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight']?.toDouble(),
      formScore: map['formScore'].toDouble(),
      formIssues: List<String>.from(map['formIssues'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'formScore': formScore,
      'formIssues': formIssues,
    };
  }
}
