// Define WorkoutPlan class first to resolve the reference issues
class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final String intensity; // 'low', 'moderate', 'high'
  final String type;
  final List<String> suitableConditions;
  final List<String> warnings;

  WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.intensity,
    required this.type,
    required this.suitableConditions,
    required this.warnings,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      intensity: json['intensity'] ?? 'moderate',
      type: json['type'] ?? 'general',
      suitableConditions: List<String>.from(json['suitableConditions'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'intensity': intensity,
      'type': type,
      'suitableConditions': suitableConditions,
      'warnings': warnings,
    };
  }
}

class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final List<MedicalCondition> conditions;
  final HealthMetrics healthMetrics;
  final String? emergencyContact;
  final String? medicalNotes;
  final String? healthDocumentUrl;
  final List<String>? allergies;
  final List<WorkoutPlan>? recommendedWorkouts;
  final DateTime? lastHealthUpdate;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.conditions,
    required this.healthMetrics,
    this.emergencyContact,
    this.medicalNotes,
    this.healthDocumentUrl,
    this.allergies,
    this.recommendedWorkouts,
    this.lastHealthUpdate,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  bool get hasChronicCondition {
    final chronicConditions = [
      'Diabetes',
      'Hypertension',
      'Chronic Kidney Disease',
      'Heart Disease',
      'Asthma',
      'Fatty Liver',
    ];

    return conditions.any(
      (condition) => chronicConditions.contains(condition.name),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      conditions:
          (json['conditions'] as List?)
              ?.map((condition) => MedicalCondition.fromJson(condition))
              .toList() ??
          [],
      healthMetrics: HealthMetrics.fromJson(json['healthMetrics']),
      emergencyContact: json['emergencyContact'],
      medicalNotes: json['medicalNotes'],
      healthDocumentUrl: json['healthDocumentUrl'],
      allergies:
          json['allergies'] != null
              ? List<String>.from(json['allergies'])
              : null,
      recommendedWorkouts:
          json['recommendedWorkouts'] != null
              ? (json['recommendedWorkouts'] as List)
                  .map((workout) => WorkoutPlan.fromJson(workout))
                  .toList()
              : null,
      lastHealthUpdate:
          json['lastHealthUpdate'] != null
              ? DateTime.parse(json['lastHealthUpdate'])
              : null,
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
      'emergencyContact': emergencyContact,
      'medicalNotes': medicalNotes,
      'healthDocumentUrl': healthDocumentUrl,
      'allergies': allergies,
      'recommendedWorkouts':
          recommendedWorkouts?.map((workout) => workout.toJson()).toList(),
      'lastHealthUpdate': lastHealthUpdate?.toIso8601String(),
      'bmi': bmi,
      'bmiCategory': bmiCategory,
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
    String? emergencyContact,
    String? medicalNotes,
    String? healthDocumentUrl,
    List<String>? allergies,
    List<WorkoutPlan>? recommendedWorkouts,
    DateTime? lastHealthUpdate,
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
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      healthDocumentUrl: healthDocumentUrl ?? this.healthDocumentUrl,
      allergies: allergies ?? this.allergies,
      recommendedWorkouts: recommendedWorkouts ?? this.recommendedWorkouts,
      lastHealthUpdate: lastHealthUpdate ?? this.lastHealthUpdate,
    );
  }
}

// MedicalCondition class
class MedicalCondition {
  final String name;
  final String description;
  final int severityLevel; // 1-5
  final List<String> limitations;
  final DateTime? diagnosisDate;
  final String? medicationDetails;

  MedicalCondition({
    required this.name,
    required this.description,
    required this.severityLevel,
    required this.limitations,
    this.diagnosisDate,
    this.medicationDetails,
  });

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      name: json['name'],
      description: json['description'],
      severityLevel: json['severityLevel'],
      limitations: List<String>.from(json['limitations'] ?? []),
      diagnosisDate:
          json['diagnosisDate'] != null
              ? DateTime.parse(json['diagnosisDate'])
              : null,
      medicationDetails: json['medicationDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'severityLevel': severityLevel,
      'limitations': limitations,
      'diagnosisDate': diagnosisDate?.toIso8601String(),
      'medicationDetails': medicationDetails,
    };
  }
}

// HealthMetrics class with additional fields for chronic conditions
class HealthMetrics {
  final int restingHeartRate;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int respiratoryRate;
  final double bloodGlucose;
  final double? cholesterolTotal;
  final double? cholesterolHDL;
  final double? cholesterolLDL;
  final double? triglycerides;
  final double? creatinine;
  final double? egfr; // For CKD monitoring
  final double? alt; // For fatty liver
  final double? ast; // For fatty liver

  HealthMetrics({
    required this.restingHeartRate,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.respiratoryRate,
    required this.bloodGlucose,
    this.cholesterolTotal,
    this.cholesterolHDL,
    this.cholesterolLDL,
    this.triglycerides,
    this.creatinine,
    this.egfr,
    this.alt,
    this.ast,
  });

  // Calculate blood pressure category
  String get bloodPressureCategory {
    if (bloodPressureSystolic < 120 && bloodPressureDiastolic < 80) {
      return 'Normal';
    } else if (bloodPressureSystolic < 130 && bloodPressureDiastolic < 80) {
      return 'Elevated';
    } else if (bloodPressureSystolic < 140 || bloodPressureDiastolic < 90) {
      return 'Hypertension Stage 1';
    } else {
      return 'Hypertension Stage 2';
    }
  }

  // Calculate blood glucose category
  String get bloodGlucoseCategory {
    if (bloodGlucose < 3.9) {
      return 'Hypoglycemia';
    } else if (bloodGlucose <= 5.5) {
      return 'Normal';
    } else if (bloodGlucose <= 7.0) {
      return 'Prediabetes';
    } else {
      return 'Hyperglycemia';
    }
  }

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      restingHeartRate: json['restingHeartRate'],
      bloodPressureSystolic: json['bloodPressureSystolic'],
      bloodPressureDiastolic: json['bloodPressureDiastolic'],
      respiratoryRate: json['respiratoryRate'],
      bloodGlucose: json['bloodGlucose'].toDouble(),
      cholesterolTotal: json['cholesterolTotal']?.toDouble(),
      cholesterolHDL: json['cholesterolHDL']?.toDouble(),
      cholesterolLDL: json['cholesterolLDL']?.toDouble(),
      triglycerides: json['triglycerides']?.toDouble(),
      creatinine: json['creatinine']?.toDouble(),
      egfr: json['egfr']?.toDouble(),
      alt: json['alt']?.toDouble(),
      ast: json['ast']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restingHeartRate': restingHeartRate,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'respiratoryRate': respiratoryRate,
      'bloodGlucose': bloodGlucose,
      'cholesterolTotal': cholesterolTotal,
      'cholesterolHDL': cholesterolHDL,
      'cholesterolLDL': cholesterolLDL,
      'triglycerides': triglycerides,
      'creatinine': creatinine,
      'egfr': egfr,
      'alt': alt,
      'ast': ast,
      'bloodPressureCategory': bloodPressureCategory,
      'bloodGlucoseCategory': bloodGlucoseCategory,
    };
  }
}
