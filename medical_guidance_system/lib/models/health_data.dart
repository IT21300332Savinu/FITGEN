import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  String userId;
  int heartRate;
  String bloodPressure;
  int steps;
  double sleepHours;

  HealthData({
    required this.userId,
    required this.heartRate,
    required this.bloodPressure,
    required this.steps,
    required this.sleepHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'steps': steps,
      'sleepHours': sleepHours,
    };
  }

  factory HealthData.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return HealthData(
      userId: data['userId'],
      heartRate: data['heartRate'],
      bloodPressure: data['bloodPressure'],
      steps: data['steps'],
      sleepHours: data['sleepHours'],
    );
  }
}
