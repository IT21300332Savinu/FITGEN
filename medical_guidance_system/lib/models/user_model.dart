class UserModel {
  final String userId;
  final String name;
  final int age;
  final String condition;

  UserModel({
    required this.userId,
    required this.name,
    required this.age,
    required this.condition,
  });

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'name': name, 'age': age, 'condition': condition};
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      name: json['name'],
      age: json['age'],
      condition: json['condition'],
    );
  }
}
