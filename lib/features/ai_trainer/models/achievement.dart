// file: lib/models/achievement.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      iconUrl: map['iconUrl'],
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt:
          map['unlockedAt'] != null
              ? (map['unlockedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }
}
