// lib/features/gamification/models/gamification_models.dart

enum BadgeType { bronze, silver, gold, platinum, diamond }

enum AchievementCategory {
  consistency,
  performance,
  milestone,
  social,
  special,
}

enum LeaderboardType { weekly, monthly, allTime }

enum PostType { workout, achievement, general }

enum ExerciseDifficulty {
  beginner(1.0),
  intermediate(1.5),
  advanced(2.0),
  expert(2.5);

  const ExerciseDifficulty(this.multiplier);
  final double multiplier;
}

class UserStats {
  final String userId;
  final int totalXP;
  final int level;
  final int totalWorkouts;
  final int totalReps;
  final int totalCalories;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final double averageFormScore;
  final DateTime lastWorkoutDate;
  final Map<String, int> exerciseCount;
  final List<String> unlockedAchievements;

  UserStats({
    required this.userId,
    required this.totalXP,
    required this.level,
    required this.totalWorkouts,
    required this.totalReps,
    required this.totalCalories,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageFormScore,
    required this.lastWorkoutDate,
    required this.exerciseCount,
    required this.unlockedAchievements,
  });

  factory UserStats.empty(String userId) {
    return UserStats(
      userId: userId,
      totalXP: 0,
      level: 1,
      totalWorkouts: 0,
      totalReps: 0,
      totalCalories: 0,
      totalMinutes: 0,
      currentStreak: 0,
      longestStreak: 0,
      averageFormScore: 0.0,
      lastWorkoutDate: DateTime.now(),
      exerciseCount: {},
      unlockedAchievements: [],
    );
  }

  // Calculate level based on XP
  static int calculateLevel(int xp) {
    return (xp / 1000).floor() + 1;
  }

  // Calculate XP needed for next level
  int getXPForNextLevel() {
    return (level * 1000) - totalXP;
  }

  UserStats copyWith({
    int? totalXP,
    int? level,
    int? totalWorkouts,
    int? totalReps,
    int? totalCalories,
    int? totalMinutes,
    int? currentStreak,
    int? longestStreak,
    double? averageFormScore,
    DateTime? lastWorkoutDate,
    Map<String, int>? exerciseCount,
    List<String>? unlockedAchievements,
  }) {
    return UserStats(
      userId: userId,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalReps: totalReps ?? this.totalReps,
      totalCalories: totalCalories ?? this.totalCalories,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      averageFormScore: averageFormScore ?? this.averageFormScore,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalXP': totalXP,
      'level': level,
      'totalWorkouts': totalWorkouts,
      'totalReps': totalReps,
      'totalCalories': totalCalories,
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageFormScore': averageFormScore,
      'lastWorkoutDate': lastWorkoutDate.toIso8601String(),
      'exerciseCount': exerciseCount,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      totalWorkouts: json['totalWorkouts'] ?? 0,
      totalReps: json['totalReps'] ?? 0,
      totalCalories: json['totalCalories'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      averageFormScore: json['averageFormScore']?.toDouble() ?? 0.0,
      lastWorkoutDate:
          json['lastWorkoutDate'] != null
              ? DateTime.parse(json['lastWorkoutDate'])
              : DateTime.now(),
      exerciseCount:
          json['exerciseCount'] != null
              ? Map<String, int>.from(json['exerciseCount'])
              : {},
      unlockedAchievements:
          json['unlockedAchievements'] != null
              ? List<String>.from(json['unlockedAchievements'])
              : [],
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final BadgeType badgeType;
  final AchievementCategory category;
  final int xpReward;
  final String iconPath;
  final Map<String, dynamic> criteria; // Flexible criteria system
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeType,
    required this.category,
    required this.xpReward,
    required this.iconPath,
    required this.criteria,
    required this.isUnlocked,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      badgeType: badgeType,
      category: category,
      xpReward: xpReward,
      iconPath: iconPath,
      criteria: criteria,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'badgeType': badgeType.name,
      'category': category.name,
      'xpReward': xpReward,
      'iconPath': iconPath,
      'criteria': criteria,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      badgeType: BadgeType.values.firstWhere(
        (e) => e.name == json['badgeType'],
      ),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      xpReward: json['xpReward'],
      iconPath: json['iconPath'],
      criteria: json['criteria'],
      isUnlocked: json['isUnlocked'],
      unlockedAt:
          json['unlockedAt'] != null
              ? DateTime.parse(json['unlockedAt'])
              : null,
    );
  }
}

class WorkoutSession {
  final String id;
  final String userId;
  final String exerciseType;
  final int repsCompleted;
  final double averageFormScore;
  final int xpEarned;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> achievementsUnlocked;

  WorkoutSession({
    required this.id,
    required this.userId,
    required this.exerciseType,
    required this.repsCompleted,
    required this.averageFormScore,
    required this.xpEarned,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.achievementsUnlocked,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'exerciseType': exerciseType,
      'repsCompleted': repsCompleted,
      'averageFormScore': averageFormScore,
      'xpEarned': xpEarned,
      'duration': duration.inSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'achievementsUnlocked': achievementsUnlocked,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      exerciseType: json['exerciseType'] ?? '',
      repsCompleted: json['repsCompleted'] ?? 0,
      averageFormScore: (json['averageFormScore'] ?? 0.0).toDouble(),
      xpEarned: json['xpEarned'] ?? 0,
      duration: Duration(seconds: json['duration'] ?? 0),
      startTime:
          json['startTime'] != null
              ? DateTime.parse(json['startTime'])
              : DateTime.now(),
      endTime:
          json['endTime'] != null
              ? DateTime.parse(json['endTime'])
              : DateTime.now(),
      achievementsUnlocked:
          json['achievementsUnlocked'] != null
              ? List<String>.from(json['achievementsUnlocked'])
              : <String>[],
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalXP;
  final int level;
  final int rank;
  final int weeklyXP;
  final int monthlyXP;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalXP,
    required this.level,
    required this.rank,
    required this.weeklyXP,
    required this.monthlyXP,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'totalXP': totalXP,
      'level': level,
      'rank': rank,
      'weeklyXP': weeklyXP,
      'monthlyXP': monthlyXP,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      totalXP: json['totalXP'],
      level: json['level'],
      rank: json['rank'],
      weeklyXP: json['weeklyXP'],
      monthlyXP: json['monthlyXP'],
    );
  }
}

class SocialPost {
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  late final DateTime timestamp;
  final List<String> likes;
  final PostType postType;
  final String? exerciseType;
  final Map<String, dynamic>? workoutData;
  final Map<String, dynamic>? achievementData;
  final List<String>? achievementIds;
  final String? imageUrl;
  final List<Comment> comments;
  final bool isPublic;

  SocialPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    DateTime? timestamp,
    DateTime? createdAt,
    required this.likes,
    required this.postType,
    this.exerciseType,
    this.workoutData,
    this.achievementData,
    this.achievementIds,
    this.imageUrl,
    List<Comment>? comments,
    bool? isPublic,
  }) : comments = comments ?? [],
       isPublic = isPublic ?? true {
    // Use createdAt if provided, otherwise use timestamp, otherwise use current time
    this.timestamp = createdAt ?? timestamp ?? DateTime.now();
  }

  // For backward compatibility
  DateTime get createdAt => timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'postType': postType.toString(),
      'exerciseType': exerciseType,
      'workoutData': workoutData,
      'achievementData': achievementData,
      'achievementIds': achievementIds,
      'imageUrl': imageUrl,
      'comments': comments.map((c) => c.toJson()).toList(),
      'isPublic': isPublic,
    };
  }

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    // Handle timestamp from Firestore - could be Timestamp, String, or null
    DateTime parsedTimestamp = DateTime.now();
    final timestampValue = json['timestamp'];

    if (timestampValue != null) {
      try {
        if (timestampValue.runtimeType.toString().contains('Timestamp')) {
          // This is a Firestore Timestamp object
          final dynamicTimestamp = timestampValue as dynamic;
          parsedTimestamp = dynamicTimestamp.toDate() as DateTime;
        } else if (timestampValue is String) {
          // ISO8601 string
          parsedTimestamp = DateTime.parse(timestampValue);
        } else if (timestampValue is int) {
          // Milliseconds since epoch
          parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue);
        } else {
          // Fallback to current time
          print('Unknown timestamp type: ${timestampValue.runtimeType}');
          parsedTimestamp = DateTime.now();
        }
      } catch (e) {
        print('Error parsing timestamp: $e, using current time');
        parsedTimestamp = DateTime.now();
      }
    }

    // Parse PostType more robustly
    PostType postType = PostType.general;
    final postTypeValue = json['postType'];
    if (postTypeValue != null) {
      if (postTypeValue is String) {
        try {
          postType = PostType.values.firstWhere(
            (type) =>
                type.toString().split('.').last == postTypeValue ||
                type.toString() == postTypeValue,
            orElse: () => PostType.general,
          );
        } catch (e) {
          print('Error parsing postType: $e, defaulting to general');
          postType = PostType.general;
        }
      }
    }

    return SocialPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      userAvatar: json['userAvatar'],
      content: json['content'] ?? '',
      timestamp: parsedTimestamp,
      likes: List<String>.from(json['likes'] ?? []),
      postType: postType,
      exerciseType: json['exerciseType'],
      workoutData: json['workoutData'] as Map<String, dynamic>?,
      achievementData: json['achievementData'] as Map<String, dynamic>?,
      achievementIds:
          json['achievementIds'] != null
              ? List<String>.from(json['achievementIds'])
              : null,
      imageUrl: json['imageUrl'],
      comments:
          (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      isPublic: json['isPublic'] ?? true,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String exerciseType;
  final int targetReps;
  final Duration duration;
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final bool isActive;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.exerciseType,
    required this.targetReps,
    required this.duration,
    required this.xpReward,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exerciseType': exerciseType,
      'targetReps': targetReps,
      'duration': duration.inDays,
      'xpReward': xpReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants,
      'isActive': isActive,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      exerciseType: json['exerciseType'],
      targetReps: json['targetReps'],
      duration: Duration(days: json['duration']),
      xpReward: json['xpReward'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: List<String>.from(json['participants']),
      isActive: json['isActive'],
    );
  }
}
