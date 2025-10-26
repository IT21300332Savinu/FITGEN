// lib/features/gamification/services/workout_integration_service.dart

import '../models/gamification_models.dart';
import 'gamification_firebase_service.dart';
import 'scoring_service.dart';

/// Service to integrate workout completion with gamification system
class WorkoutIntegrationService {
  /// Call this when a workout is completed to update gamification stats
  static Future<Map<String, dynamic>> onWorkoutCompleted({
    required String exerciseType,
    required int repCount,
    required double formScore,
    required int durationMinutes,
  }) async {
    try {
      print('🏃‍♂️ Processing workout completion...');
      print(
        '📝 Exercise: $exerciseType, Reps: $repCount, Form: $formScore%, Duration: ${durationMinutes}min',
      );

      // Get current user ID
      final userId = GamificationFirebaseService.currentUserId;
      print('🆔 Current User ID: $userId');

      if (userId == null) {
        print('❌ No user logged in');
        return {'success': false, 'error': 'No user logged in'};
      }

      // Get current user stats to calculate XP properly
      final currentStats = await GamificationFirebaseService.getUserStats(
        userId,
      );
      print('📊 Current User Stats: ${currentStats?.toJson()}');

      if (currentStats == null) {
        print('❌ No user stats found, initializing...');
        await GamificationFirebaseService.initializeUserStats(userId, 'User');
        return onWorkoutCompleted(
          exerciseType: exerciseType,
          repCount: repCount,
          formScore: formScore,
          durationMinutes: durationMinutes,
        );
      }

      // Calculate XP earned
      final xpEarned = ScoringService.calculateXP(
        formScore: formScore,
        repCount: repCount,
        exerciseType: exerciseType,
        userStats: currentStats,
      );
      print('🎯 Calculated XP: $xpEarned');

      // Update user stats in Firebase
      print('💾 Updating Firebase stats...');
      await GamificationFirebaseService.updateStatsAfterWorkout(
        exerciseType: exerciseType,
        repCount: repCount,
        formScore: formScore,
        durationMinutes: durationMinutes,
      );
      print('✅ Firebase stats updated');

      // Post workout to social feed (optional - can be enabled by user preference)
      print('📱 Posting to social feed...');
      await GamificationFirebaseService.postWorkoutCompletion(
        exerciseType: exerciseType,
        repCount: repCount,
        formScore: formScore,
        durationMinutes: durationMinutes,
        xpEarned: xpEarned,
      );
      print('✅ Social feed updated');

      // Get updated stats to check for new achievements
      final updatedStats = await GamificationFirebaseService.getUserStats(
        userId,
      );

      // Find newly unlocked achievements
      final newAchievements = <String>[];
      if (updatedStats != null) {
        final previousAchievements = currentStats.unlockedAchievements;
        newAchievements.addAll(
          updatedStats.unlockedAchievements.where(
            (achievement) => !previousAchievements.contains(achievement),
          ),
        );
      }

      print('✅ Workout processed successfully');
      print('💪 XP Earned: $xpEarned');
      print('🎖️ New Achievements: ${newAchievements.length}');

      return {
        'success': true,
        'xpEarned': xpEarned,
        'newLevel': updatedStats?.level ?? currentStats.level,
        'newAchievements': newAchievements,
        'currentStreak':
            updatedStats?.currentStreak ?? currentStats.currentStreak,
        'totalXP': updatedStats?.totalXP ?? currentStats.totalXP,
        'formScore': formScore,
        'repCount': repCount,
        'exerciseType': exerciseType,
      };
    } catch (e) {
      print('❌ Error processing workout completion: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user's current gamification stats
  static Future<UserStats?> getCurrentStats() async {
    final userId = GamificationFirebaseService.currentUserId;
    if (userId == null) return null;
    return await GamificationFirebaseService.getUserStats(userId);
  }

  /// Initialize gamification for a new user
  static Future<void> initializeForUser(String userId, String username) async {
    await GamificationFirebaseService.initializeUserStats(userId, username);
  }

  /// Get current leaderboard position
  static Future<int> getCurrentRank() async {
    final userId = GamificationFirebaseService.currentUserId;
    if (userId == null) return -1;

    return await GamificationFirebaseService.getUserRank(
      userId,
      LeaderboardType.allTime,
    );
  }

  /// Get motivation message based on recent performance
  static String getMotivationMessage(Map<String, dynamic> workoutResult) {
    final formScore = workoutResult['formScore'] as double? ?? 0.0;
    final xpEarned = workoutResult['xpEarned'] as int? ?? 0;
    final newAchievements = workoutResult['newAchievements'] as List? ?? [];
    final currentStreak = workoutResult['currentStreak'] as int? ?? 0;

    if (newAchievements.isNotEmpty) {
      return "🏆 Achievement Unlocked! You're crushing it! Keep up the amazing work!";
    }

    if (formScore >= 95) {
      return "🎯 Perfect form! You earned $xpEarned XP with that flawless technique!";
    }

    if (formScore >= 85) {
      return "💪 Excellent workout! $xpEarned XP earned with great form!";
    }

    if (currentStreak >= 7) {
      return "🔥 $currentStreak-day streak! You're on fire! $xpEarned XP earned!";
    }

    if (currentStreak >= 3) {
      return "🎉 Great consistency! $currentStreak days in a row! $xpEarned XP earned!";
    }

    if (xpEarned >= 100) {
      return "⭐ Amazing workout! You earned $xpEarned XP! Keep pushing!";
    }

    return "💪 Great job! You earned $xpEarned XP! Every workout counts!";
  }

  /// Show level up animation/notification if user leveled up
  static bool hasLeveledUp(Map<String, dynamic> workoutResult) {
    final previousLevel = workoutResult['previousLevel'] as int? ?? 1;
    final newLevel = workoutResult['newLevel'] as int? ?? 1;
    return newLevel > previousLevel;
  }

  /// Format workout summary for display
  static Map<String, String> formatWorkoutSummary(
    Map<String, dynamic> workoutResult,
  ) {
    final formScore = workoutResult['formScore'] as double? ?? 0.0;
    final repCount = workoutResult['repCount'] as int? ?? 0;
    final xpEarned = workoutResult['xpEarned'] as int? ?? 0;
    final exerciseType = workoutResult['exerciseType'] as String? ?? 'Exercise';
    final currentStreak = workoutResult['currentStreak'] as int? ?? 0;
    final totalXP = workoutResult['totalXP'] as int? ?? 0;
    final newLevel = workoutResult['newLevel'] as int? ?? 1;

    return {
      'exercise': exerciseType,
      'reps': '$repCount reps',
      'form': '${formScore.toStringAsFixed(1)}%',
      'xp': '+$xpEarned XP',
      'level': 'Level $newLevel',
      'streak': '$currentStreak days',
      'totalXP': '$totalXP total XP',
    };
  }
}
