class UserProfile {
  final String id;
  final int age;
  final String gender;
  final String personalGoal;
  final bool diabetes;
  final String? diabetesType;
  final bool hypertension;
  final bool ckd;
  final bool liverDisease;
  final List<String> reportUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.age,
    required this.gender,
    required this.personalGoal,
    required this.diabetes,
    this.diabetesType,
    required this.hypertension,
    required this.ckd,
    required this.liverDisease,
    required this.reportUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'gender': gender,
      'personalGoal': personalGoal,
      'diabetes': diabetes,
      'diabetesType': diabetesType,
      'hypertension': hypertension,
      'ckd': ckd,
      'liverDisease': liverDisease,
      'reportUrls': reportUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      personalGoal: map['personalGoal'] ?? '',
      diabetes: map['diabetes'] ?? false,
      diabetesType: map['diabetesType'],
      hypertension: map['hypertension'] ?? false,
      ckd: map['ckd'] ?? false,
      liverDisease: map['liverDisease'] ?? false,
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
    int? age,
    String? gender,
    String? personalGoal,
    bool? diabetes,
    String? diabetesType,
    bool? hypertension,
    bool? ckd,
    bool? liverDisease,
    List<String>? reportUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      personalGoal: personalGoal ?? this.personalGoal,
      diabetes: diabetes ?? this.diabetes,
      diabetesType: diabetesType ?? this.diabetesType,
      hypertension: hypertension ?? this.hypertension,
      ckd: ckd ?? this.ckd,
      liverDisease: liverDisease ?? this.liverDisease,
      reportUrls: reportUrls ?? this.reportUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
