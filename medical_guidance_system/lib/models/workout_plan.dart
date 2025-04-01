class WorkoutPlan {
  final String userId;
  final List<String> exercises;
  final int breakTime;

  WorkoutPlan({
    required this.userId,
    required this.exercises,
    required this.breakTime,
  });

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'exercises': exercises, 'breakTime': breakTime};
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      userId: json['userId'],
      exercises: List<String>.from(json['exercises']),
      breakTime: json['breakTime'],
    );
  }
}
