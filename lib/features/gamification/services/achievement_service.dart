// lib/features/gamification/services/achievement_service.dart

import '../models/gamification_models.dart';

class AchievementService {
  
  /// Get achievement by ID
  static Achievement? getAchievementById(String id) {
    try {
      return getAllAchievements().firstWhere((achievement) => achievement.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Pre-defined achievements list
  static List<Achievement> getAllAchievements() {
    return [
      // Consistency Achievements
      Achievement(
        id: 'first_workout',
        title: 'First Steps',
        description: 'Complete your first workout',
        badgeType: BadgeType.bronze,
        category: AchievementCategory.milestone,
        xpReward: 50,
        iconPath: 'assets/badges/first_workout.png',
        criteria: {'workouts': 1},
        isUnlocked: false,
      ),
      Achievement(
        id: 'workout_streak_3',
        title: 'Getting Started',
        description: 'Workout for 3 days in a row',
        badgeType: BadgeType.bronze,
        category: AchievementCategory.consistency,
        xpReward: 100,
        iconPath: 'assets/badges/streak_3.png',
        criteria: {'streak': 3},
        isUnlocked: false,
      ),
      Achievement(
        id: 'workout_streak_7',
        title: 'Week Warrior',
        description: 'Workout for 7 days in a row',
        badgeType: BadgeType.silver,
        category: AchievementCategory.consistency,
        xpReward: 200,
        iconPath: 'assets/badges/streak_7.png',
        criteria: {'streak': 7},
        isUnlocked: false,
      ),
      Achievement(
        id: 'workout_streak_30',
        title: 'Consistency King',
        description: 'Workout for 30 days in a row',
        badgeType: BadgeType.gold,
        category: AchievementCategory.consistency,
        xpReward: 500,
        iconPath: 'assets/badges/streak_30.png',
        criteria: {'streak': 30},
        isUnlocked: false,
      ),
      Achievement(
        id: 'workout_streak_100',
        title: 'Unstoppable Force',
        description: 'Workout for 100 days in a row',
        badgeType: BadgeType.diamond,
        category: AchievementCategory.consistency,
        xpReward: 1000,
        iconPath: 'assets/badges/streak_100.png',
        criteria: {'streak': 100},
        isUnlocked: false,
      ),

      // Performance Achievements
      Achievement(
        id: 'perfect_form_workout',
        title: 'Form Master',
        description: 'Complete a workout with 95%+ form score',
        badgeType: BadgeType.silver,
        category: AchievementCategory.performance,
        xpReward: 150,
        iconPath: 'assets/badges/perfect_form.png',
        criteria: {'formScore': 95.0},
        isUnlocked: false,
      ),
      Achievement(
        id: 'rep_master_50',
        title: 'Rep Master',
        description: 'Complete 50 reps in a single workout',
        badgeType: BadgeType.bronze,
        category: AchievementCategory.performance,
        xpReward: 100,
        iconPath: 'assets/badges/rep_master.png',
        criteria: {'reps': 50},
        isUnlocked: false,
      ),
      Achievement(
        id: 'rep_master_100',
        title: 'Century Club',
        description: 'Complete 100 reps in a single workout',
        badgeType: BadgeType.gold,
        category: AchievementCategory.performance,
        xpReward: 300,
        iconPath: 'assets/badges/century.png',
        criteria: {'reps': 100},
        isUnlocked: false,
      ),
      Achievement(
        id: 'endurance_master',
        title: 'Endurance Master',
        description: 'Complete a 30-minute workout',
        badgeType: BadgeType.gold,
        category: AchievementCategory.performance,
        xpReward: 250,
        iconPath: 'assets/badges/endurance.png',
        criteria: {'duration': 30},
        isUnlocked: false,
      ),

      // Milestone Achievements
      Achievement(
        id: 'total_workouts_10',
        title: 'Committed',
        description: 'Complete 10 total workouts',
        badgeType: BadgeType.bronze,
        category: AchievementCategory.milestone,
        xpReward: 150,
        iconPath: 'assets/badges/committed.png',
        criteria: {'totalWorkouts': 10},
        isUnlocked: false,
      ),
      Achievement(
        id: 'total_workouts_50',
        title: 'Fitness Enthusiast',
        description: 'Complete 50 total workouts',
        badgeType: BadgeType.silver,
        category: AchievementCategory.milestone,
        xpReward: 400,
        iconPath: 'assets/badges/enthusiast.png',
        criteria: {'totalWorkouts': 50},
        isUnlocked: false,
      ),
      Achievement(
        id: 'total_workouts_100',
        title: 'Fitness Pro',
        description: 'Complete 100 total workouts',
        badgeType: BadgeType.gold,
        category: AchievementCategory.milestone,
        xpReward: 750,
        iconPath: 'assets/badges/pro.png',
        criteria: {'totalWorkouts': 100},
        isUnlocked: false,
      ),
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        badgeType: BadgeType.silver,
        category: AchievementCategory.milestone,
        xpReward: 200,
        iconPath: 'assets/badges/level_5.png',
        criteria: {'level': 5},
        isUnlocked: false,
      ),
      Achievement(
        id: 'level_10',
        title: 'Fitness Legend',
        description: 'Reach level 10',
        badgeType: BadgeType.gold,
        category: AchievementCategory.milestone,
        xpReward: 500,
        iconPath: 'assets/badges/level_10.png',
        criteria: {'level': 10},
        isUnlocked: false,
      ),

      // Exercise-specific Achievements
      Achievement(
        id: 'bicep_specialist',
        title: 'Bicep Specialist',
        description: 'Complete 25 bicep curl workouts',
        badgeType: BadgeType.silver,
        category: AchievementCategory.special,
        xpReward: 200,
        iconPath: 'assets/badges/bicep_specialist.png',
        criteria: {'exerciseType': 'bicepCurl', 'count': 25},
        isUnlocked: false,
      ),
      Achievement(
        id: 'squat_master',
        title: 'Squat Master',
        description: 'Complete 25 squat workouts',
        badgeType: BadgeType.silver,
        category: AchievementCategory.special,
        xpReward: 200,
        iconPath: 'assets/badges/squat_master.png',
        criteria: {'exerciseType': 'squat', 'count': 25},
        isUnlocked: false,
      ),
      Achievement(
        id: 'pushup_champion',
        title: 'Push-up Champion',
        description: 'Complete 25 push-up workouts',
        badgeType: BadgeType.silver,
        category: AchievementCategory.special,
        xpReward: 200,
        iconPath: 'assets/badges/pushup_champion.png',
        criteria: {'exerciseType': 'pushup', 'count': 25},
        isUnlocked: false,
      ),
      Achievement(
        id: 'versatile_athlete',
        title: 'Versatile Athlete',
        description: 'Complete workouts for all exercise types',
        badgeType: BadgeType.platinum,
        category: AchievementCategory.special,
        xpReward: 400,
        iconPath: 'assets/badges/versatile.png',
        criteria: {'allExercises': true},
        isUnlocked: false,
      ),

      // Social Achievements
      Achievement(
        id: 'social_sharer',
        title: 'Social Sharer',
        description: 'Share your first workout',
        badgeType: BadgeType.bronze,
        category: AchievementCategory.social,
        xpReward: 75,
        iconPath: 'assets/badges/social_sharer.png',
        criteria: {'shares': 1},
        isUnlocked: false,
      ),
      Achievement(
        id: 'motivator',
        title: 'Motivator',
        description: 'Give 10 likes to other users',
        badgeType: BadgeType.silver,
        category: AchievementCategory.social,
        xpReward: 100,
        iconPath: 'assets/badges/motivator.png',
        criteria: {'likes': 10},
        isUnlocked: false,
      ),
    ];
  }

  /// Check if user has unlocked any new achievements
  static List<Achievement> checkForNewAchievements(
    UserStats userStats,
    WorkoutSession? latestSession,
    List<Achievement> currentAchievements,
  ) {
    List<Achievement> newlyUnlocked = [];
    List<Achievement> allAchievements = getAllAchievements();

    for (Achievement achievement in allAchievements) {
      // Skip if already unlocked
      if (userStats.unlockedAchievements.contains(achievement.id)) {
        continue;
      }

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_workout':
          shouldUnlock = userStats.totalWorkouts >= 1;
          break;
        case 'workout_streak_3':
          shouldUnlock = userStats.currentStreak >= 3;
          break;
        case 'workout_streak_7':
          shouldUnlock = userStats.currentStreak >= 7;
          break;
        case 'workout_streak_30':
          shouldUnlock = userStats.currentStreak >= 30;
          break;
        case 'workout_streak_100':
          shouldUnlock = userStats.currentStreak >= 100;
          break;
        case 'perfect_form_workout':
          shouldUnlock = latestSession != null && latestSession.averageFormScore >= 95.0;
          break;
        case 'rep_master_50':
          shouldUnlock = latestSession != null && latestSession.repsCompleted >= 50;
          break;
        case 'rep_master_100':
          shouldUnlock = latestSession != null && latestSession.repsCompleted >= 100;
          break;
        case 'endurance_master':
          shouldUnlock = latestSession != null && latestSession.duration.inMinutes >= 30;
          break;
        case 'total_workouts_10':
          shouldUnlock = userStats.totalWorkouts >= 10;
          break;
        case 'total_workouts_50':
          shouldUnlock = userStats.totalWorkouts >= 50;
          break;
        case 'total_workouts_100':
          shouldUnlock = userStats.totalWorkouts >= 100;
          break;
        case 'level_5':
          shouldUnlock = userStats.level >= 5;
          break;
        case 'level_10':
          shouldUnlock = userStats.level >= 10;
          break;
        case 'bicep_specialist':
          shouldUnlock = (userStats.exerciseCount['bicepCurl'] ?? 0) >= 25;
          break;
        case 'squat_master':
          shouldUnlock = (userStats.exerciseCount['squat'] ?? 0) >= 25;
          break;
        case 'pushup_champion':
          shouldUnlock = (userStats.exerciseCount['pushup'] ?? 0) >= 25;
          break;
        case 'versatile_athlete':
          shouldUnlock = _hasCompletedAllExercises(userStats.exerciseCount);
          break;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
      }
    }

    return newlyUnlocked;
  }

  /// Check if user has completed all exercise types
  static bool _hasCompletedAllExercises(Map<String, int> exerciseCount) {
    List<String> requiredExercises = [
      'bicepCurl',
      'squat',
      'pushup',
      'shoulderPress',
      'armCircling',
    ];

    for (String exercise in requiredExercises) {
      if ((exerciseCount[exercise] ?? 0) == 0) {
        return false;
      }
    }
    return true;
  }

  /// Get achievements by category
  static List<Achievement> getAchievementsByCategory(
    AchievementCategory category,
    List<String> unlockedIds,
  ) {
    return getAllAchievements()
        .where((achievement) => achievement.category == category)
        .map((achievement) => achievement.copyWith(
              isUnlocked: unlockedIds.contains(achievement.id),
              unlockedAt: unlockedIds.contains(achievement.id) ? DateTime.now() : null,
            ))
        .toList();
  }

  /// Get user's unlocked achievements
  static List<Achievement> getUnlockedAchievements(List<String> unlockedIds) {
    return getAllAchievements()
        .where((achievement) => unlockedIds.contains(achievement.id))
        .map((achievement) => achievement.copyWith(
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            ))
        .toList();
  }

  /// Get achievement progress for display
  static Map<String, dynamic> getAchievementProgress(
    Achievement achievement,
    UserStats userStats,
    WorkoutSession? latestSession,
  ) {
    Map<String, dynamic> progress = {
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'isUnlocked': achievement.isUnlocked,
      'progress': 0.0,
      'current': 0,
      'target': 0,
      'progressText': '',
    };

    switch (achievement.id) {
      case 'workout_streak_3':
      case 'workout_streak_7':
      case 'workout_streak_30':
      case 'workout_streak_100':
        int target = achievement.criteria['streak'];
        progress['current'] = userStats.currentStreak;
        progress['target'] = target;
        progress['progress'] = (userStats.currentStreak / target).clamp(0.0, 1.0);
        progress['progressText'] = '${userStats.currentStreak}/$target days';
        break;
      case 'total_workouts_10':
      case 'total_workouts_50':
      case 'total_workouts_100':
        int target = achievement.criteria['totalWorkouts'];
        progress['current'] = userStats.totalWorkouts;
        progress['target'] = target;
        progress['progress'] = (userStats.totalWorkouts / target).clamp(0.0, 1.0);
        progress['progressText'] = '${userStats.totalWorkouts}/$target workouts';
        break;
      case 'level_5':
      case 'level_10':
        int target = achievement.criteria['level'];
        progress['current'] = userStats.level;
        progress['target'] = target;
        progress['progress'] = (userStats.level / target).clamp(0.0, 1.0);
        progress['progressText'] = 'Level ${userStats.level}/$target';
        break;
      case 'bicep_specialist':
      case 'squat_master':
      case 'pushup_champion':
        String exerciseType = achievement.criteria['exerciseType'];
        int target = achievement.criteria['count'];
        int current = userStats.exerciseCount[exerciseType] ?? 0;
        progress['current'] = current;
        progress['target'] = target;
        progress['progress'] = (current / target).clamp(0.0, 1.0);
        progress['progressText'] = '$current/$target workouts';
        break;
      default:
        progress['progress'] = achievement.isUnlocked ? 1.0 : 0.0;
        progress['progressText'] = achievement.isUnlocked ? 'Completed' : 'Not unlocked';
    }

    return progress;
  }

  /// Get next achievable achievements for motivation
  static List<Achievement> getNextAchievements(
    UserStats userStats,
    List<String> unlockedIds,
  ) {
    List<Achievement> nextAchievements = [];
    List<Achievement> allAchievements = getAllAchievements();

    for (Achievement achievement in allAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool isNextAchievable = false;

      switch (achievement.id) {
        case 'workout_streak_3':
          isNextAchievable = userStats.currentStreak >= 1;
          break;
        case 'workout_streak_7':
          isNextAchievable = userStats.currentStreak >= 3;
          break;
        case 'total_workouts_10':
          isNextAchievable = userStats.totalWorkouts >= 5;
          break;
        case 'perfect_form_workout':
          isNextAchievable = userStats.averageFormScore >= 80;
          break;
        case 'level_5':
          isNextAchievable = userStats.level >= 3;
          break;
      }

      if (isNextAchievable) {
        nextAchievements.add(achievement);
      }
    }

    return nextAchievements.take(3).toList(); // Return top 3 next achievements
  }
}