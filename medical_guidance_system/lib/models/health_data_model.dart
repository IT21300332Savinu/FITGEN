import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  final String? id;
  final String name;
  final double kpm;
  final double mmol;
  final double percentage;

  HealthData({
    this.id,
    required this.name,
    required this.kpm,
    required this.mmol,
    required this.percentage,
  });

  // Convert Firestore Document → HealthData object
  factory HealthData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HealthData(
      id: doc.id,
      name: data['name'] ?? '',
      kpm: (data['kpm'] as num?)?.toDouble() ?? 0.0,
      mmol: (data['mmol'] as num?)?.toDouble() ?? 0.0,
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert HealthData → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'kpm': kpm,
      'mmol': mmol,
      'percentage': percentage,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
