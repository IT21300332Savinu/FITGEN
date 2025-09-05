class UserProfile {
  final String id;
  final String name; // Added name field
  final int age;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String personalGoal;
  final bool diabetes;
  final String? diabetesType;
  final bool hypertension;
  final bool ckd;
  final bool liverDisease;
  final bool fattyLiver; // New condition
  final List<String> reportUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name, // Added name parameter
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.personalGoal,
    required this.diabetes,
    this.diabetesType,
    required this.hypertension,
    required this.ckd,
    required this.liverDisease,
    required this.fattyLiver,
    required this.reportUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Get selected conditions count
  int get selectedConditionsCount {
    int count = 0;
    if (diabetes) count++;
    if (hypertension) count++;
    if (ckd) count++;
    if (liverDisease) count++;
    if (fattyLiver) count++;
    return count;
  }

  // Get list of conditions
  List<String> get activeConditions {
    List<String> conditions = [];
    if (diabetes) conditions.add('Diabetes (${diabetesType ?? 'Unknown'})');
    if (hypertension) conditions.add('Hypertension');
    if (ckd) conditions.add('Chronic Kidney Disease');
    if (liverDisease) conditions.add('Liver Disease');
    if (fattyLiver) conditions.add('Fatty Liver');
    return conditions;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name, // Added name to map
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'personalGoal': personalGoal,
      'diabetes': diabetes,
      'diabetesType': diabetesType,
      'hypertension': hypertension,
      'ckd': ckd,
      'liverDisease': liverDisease,
      'fattyLiver': fattyLiver,
      'reportUrls': reportUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '', // Added name from map with fallback
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      height: (map['height'] ?? 0.0).toDouble(),
      weight: (map['weight'] ?? 0.0).toDouble(),
      personalGoal: map['personalGoal'] ?? '',
      diabetes: map['diabetes'] ?? false,
      diabetesType: map['diabetesType'],
      hypertension: map['hypertension'] ?? false,
      ckd: map['ckd'] ?? false,
      liverDisease: map['liverDisease'] ?? false,
      fattyLiver: map['fattyLiver'] ?? false,
      reportUrls: List<String>.from(map['reportUrls'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name, // Added name parameter
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? personalGoal,
    bool? diabetes,
    String? diabetesType,
    bool? hypertension,
    bool? ckd,
    bool? liverDisease,
    bool? fattyLiver,
    List<String>? reportUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name, // Added name to copyWith
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      personalGoal: personalGoal ?? this.personalGoal,
      diabetes: diabetes ?? this.diabetes,
      diabetesType: diabetesType ?? this.diabetesType,
      hypertension: hypertension ?? this.hypertension,
      ckd: ckd ?? this.ckd,
      liverDisease: liverDisease ?? this.liverDisease,
      fattyLiver: fattyLiver ?? this.fattyLiver,
      reportUrls: reportUrls ?? this.reportUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
