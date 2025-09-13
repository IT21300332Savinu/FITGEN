// file: lib/models/user_profile.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String name;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String fitnessGoal; // weight_loss, muscle_gain, general_fitness
  final List<String> healthConditions;
  final Map<String, dynamic> preferences;
  final int totalWorkouts;
  final int totalCaloriesBurned;
  final int totalWorkoutMinutes;
  final int experiencePoints;
  final DateTime createdAt;
  final DateTime? lastWorkout;

  UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    this.healthConditions = const [],
    this.preferences = const {},
    this.totalWorkouts = 0,
    this.totalCaloriesBurned = 0,
    this.totalWorkoutMinutes = 0,
    this.experiencePoints = 0,
    DateTime? createdAt,
    this.lastWorkout,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'],
      name: map['name'],
      age: map['age'],
      weight: map['weight'].toDouble(),
      height: map['height'].toDouble(),
      fitnessGoal: map['fitnessGoal'],
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalCaloriesBurned: map['totalCaloriesBurned'] ?? 0,
      totalWorkoutMinutes: map['totalWorkoutMinutes'] ?? 0,
      experiencePoints: map['experiencePoints'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastWorkout:
          map['lastWorkout'] != null
              ? (map['lastWorkout'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessGoal': fitnessGoal,
      'healthConditions': healthConditions,
      'preferences': preferences,
      'totalWorkouts': totalWorkouts,
      'totalCaloriesBurned': totalCaloriesBurned,
      'totalWorkoutMinutes': totalWorkoutMinutes,
      'experiencePoints': experiencePoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastWorkout':
          lastWorkout != null ? Timestamp.fromDate(lastWorkout!) : null,
    };
  }
}
