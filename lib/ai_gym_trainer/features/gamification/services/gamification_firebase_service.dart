// lib/features/gamification/services/gamification_firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gamification_models.dart';
import 'scoring_service.dart';
import 'achievement_service.dart';

class GamificationFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID from Firebase Auth
  static String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ===== USER STATS MANAGEMENT =====

  /// Check if username already exists
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('gamification_profile')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('❌ Error checking username availability: $e');
      return false; // Assume unavailable on error to be safe
    }
  }

  /// Initialize user stats when user first signs up
  static Future<void> initializeUserStats(
    String userId,
    String username,
  ) async {
    try {
      final userStats = UserStats(
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

      await _firestore
          .collection('gamification_stats')
          .doc(userId)
          .set(userStats.toJson());

      await _firestore.collection('gamification_profile').doc(userId).set({
        'username': username,
        'profileImageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });

      print('✅ Initialized gamification stats for user: $userId');
    } catch (e) {
      print('❌ Error initializing user stats: $e');
      rethrow;
    }
  }

  /// Get user stats from Firebase
  static Future<UserStats?> getUserStats(String? userId) async {
    if (userId == null) return null;

    try {
      final doc =
          await _firestore.collection('gamification_stats').doc(userId).get();

      if (doc.exists) {
        return UserStats.fromJson(doc.data()!);
      } else {
        // If stats don't exist, initialize them
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'User';
          await initializeUserStats(userId, username);
          return getUserStats(
            userId,
          ); // Recursive call to get the newly created stats
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user stats: $e');
      return null;
    }
  }

  /// Update user stats after a workout session
  static Future<void> updateStatsAfterWorkout({
    required String exerciseType,
    required int repCount,
    required double formScore,
    required int durationMinutes,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      print('❌ No user logged in');
      return;
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final statsRef = _firestore
            .collection('gamification_stats')
            .doc(userId);
        final statsDoc = await transaction.get(statsRef);

        UserStats currentStats;
        if (statsDoc.exists) {
          currentStats = UserStats.fromJson(statsDoc.data()!);
        } else {
          // Initialize if doesn't exist
          await initializeUserStats(userId, 'User');
          final newStatsDoc = await statsRef.get();
          currentStats = UserStats.fromJson(newStatsDoc.data()!);
        }

        // Calculate XP using the scoring service
        final xpEarned = ScoringService.calculateXP(
          formScore: formScore,
          repCount: repCount,
          exerciseType: exerciseType,
          userStats: currentStats,
        );

        // Update exercise count
        final updatedExerciseCount = Map<String, int>.from(
          currentStats.exerciseCount,
        );
        updatedExerciseCount[exerciseType] =
            (updatedExerciseCount[exerciseType] ?? 0) + 1;

        // Calculate streak
        final today = DateTime.now();
        final lastWorkout = currentStats.lastWorkoutDate;
        int newStreak = currentStats.currentStreak;

        if (lastWorkout.difference(today).inDays.abs() == 1) {
          // Consecutive day
          newStreak++;
        } else if (lastWorkout.difference(today).inDays.abs() > 1) {
          // Streak broken
          newStreak = 1;
        } else {
          // Same day workout
          newStreak =
              currentStats.currentStreak > 0 ? currentStats.currentStreak : 1;
        }

        // Calculate new average form score
        final totalWorkouts = currentStats.totalWorkouts + 1;
        final newAverageFormScore =
            ((currentStats.averageFormScore * currentStats.totalWorkouts) +
                formScore) /
            totalWorkouts;

        // Calculate estimated calories burned (simple estimation)
        final estimatedCalories = _calculateCaloriesBurned(
          durationMinutes,
          exerciseType,
        );

        // Create updated stats
        final updatedStats = UserStats(
          userId: userId,
          totalXP: currentStats.totalXP + xpEarned,
          level: UserStats.calculateLevel(currentStats.totalXP + xpEarned),
          totalWorkouts: totalWorkouts,
          totalReps: currentStats.totalReps + repCount,
          totalCalories: currentStats.totalCalories + estimatedCalories,
          totalMinutes: currentStats.totalMinutes + durationMinutes,
          currentStreak: newStreak,
          longestStreak:
              newStreak > currentStats.longestStreak
                  ? newStreak
                  : currentStats.longestStreak,
          averageFormScore: newAverageFormScore,
          lastWorkoutDate: today,
          exerciseCount: updatedExerciseCount,
          unlockedAchievements: currentStats.unlockedAchievements,
        );

        // Update in transaction
        transaction.set(statsRef, updatedStats.toJson());

        // Check for new achievements
        await _checkAndUnlockAchievements(updatedStats, transaction);

        print('✅ Updated stats: +$xpEarned XP, Level ${updatedStats.level}');
      });
    } catch (e) {
      print('❌ Error updating stats after workout: $e');
      rethrow;
    }
  }

  /// Check and unlock achievements
  static Future<void> _checkAndUnlockAchievements(
    UserStats stats,
    Transaction transaction,
  ) async {
    try {
      final allAchievements = AchievementService.getAllAchievements();
      final newUnlocked = <String>[];

      for (final achievement in allAchievements) {
        if (!stats.unlockedAchievements.contains(achievement.id)) {
          if (_checkAchievementCriteria(achievement, stats)) {
            newUnlocked.add(achievement.id);
          }
        }
      }

      if (newUnlocked.isNotEmpty) {
        final updatedAchievements = [
          ...stats.unlockedAchievements,
          ...newUnlocked,
        ];
        final statsRef = _firestore
            .collection('gamification_stats')
            .doc(stats.userId);

        transaction.update(statsRef, {
          'unlockedAchievements': updatedAchievements,
        });

        // Create achievement unlock records
        for (final achievementId in newUnlocked) {
          final unlockRef = _firestore
              .collection('achievement_unlocks')
              .doc('${stats.userId}_$achievementId');

          transaction.set(unlockRef, {
            'userId': stats.userId,
            'achievementId': achievementId,
            'unlockedAt': FieldValue.serverTimestamp(),
          });
        }

        print('🏆 Unlocked ${newUnlocked.length} new achievements!');
      }
    } catch (e) {
      print('❌ Error checking achievements: $e');
    }
  }

  /// Check if achievement criteria is met
  static bool _checkAchievementCriteria(
    Achievement achievement,
    UserStats stats,
  ) {
    switch (achievement.id) {
      case 'first_workout':
        return stats.totalWorkouts >= 1;
      case 'workout_streak_3':
        return stats.currentStreak >= 3;
      case 'workout_streak_7':
        return stats.currentStreak >= 7;
      case 'workout_streak_30':
        return stats.currentStreak >= 30;
      case 'total_workouts_10':
        return stats.totalWorkouts >= 10;
      case 'total_workouts_50':
        return stats.totalWorkouts >= 50;
      case 'total_workouts_100':
        return stats.totalWorkouts >= 100;
      case 'perfect_form_workout':
        return stats.averageFormScore >= 95.0;
      case 'rep_master_50':
        return stats.totalReps >= 50;
      case 'rep_master_500':
        return stats.totalReps >= 500;
      case 'rep_master_1000':
        return stats.totalReps >= 1000;
      case 'level_up_5':
        return stats.level >= 5;
      case 'level_up_10':
        return stats.level >= 10;
      case 'level_up_20':
        return stats.level >= 20;
      case 'xp_master_1000':
        return stats.totalXP >= 1000;
      case 'xp_master_5000':
        return stats.totalXP >= 5000;
      case 'xp_master_10000':
        return stats.totalXP >= 10000;
      default:
        return false;
    }
  }

  // ===== LEADERBOARD MANAGEMENT =====

  /// Get leaderboard data
  static Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardType type = LeaderboardType.weekly,
    int limit = 50,
  }) async {
    try {
      // Simplified query - just get all users and filter in memory to avoid index requirements
      final statsQuery =
          await _firestore
              .collection('gamification_stats')
              .orderBy('totalXP', descending: true)
              .limit(limit * 2) // Get more to account for filtering
              .get();

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in statsQuery.docs) {
        final stats = UserStats.fromJson(doc.data());

        // Apply time filtering in memory based on leaderboard type
        DateTime cutoffDate;
        switch (type) {
          case LeaderboardType.weekly:
            cutoffDate = DateTime.now().subtract(const Duration(days: 7));
            break;
          case LeaderboardType.monthly:
            cutoffDate = DateTime.now().subtract(const Duration(days: 30));
            break;
          case LeaderboardType.allTime:
            cutoffDate = DateTime(2020); // Far in the past
            break;
        }

        // Skip if user hasn't been active in the time period (except for all-time)
        if (type != LeaderboardType.allTime &&
            stats.lastWorkoutDate.isBefore(cutoffDate)) {
          continue;
        }

        // Get user profile
        final profileDoc =
            await _firestore
                .collection('gamification_profile')
                .doc(stats.userId)
                .get();

        if (profileDoc.exists) {
          final profileData = profileDoc.data()!;

          entries.add(
            LeaderboardEntry(
              rank: rank,
              userId: stats.userId,
              username: profileData['username'] ?? 'Anonymous',
              totalXP: stats.totalXP,
              level: stats.level,
              avatarUrl: profileData['profileImageUrl'] ?? '',
              weeklyXP: 0, // Will be calculated separately if needed
              monthlyXP: 0, // Will be calculated separately if needed
            ),
          );
          rank++;

          // Stop if we've reached the limit
          if (entries.length >= limit) {
            break;
          }
        }
      }

      return entries;
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }

  /// Get user's rank on leaderboard
  static Future<int> getUserRank(String userId, LeaderboardType type) async {
    try {
      final leaderboard = await getLeaderboard(type: type, limit: 1000);
      for (int i = 0; i < leaderboard.length; i++) {
        if (leaderboard[i].userId == userId) {
          return i + 1;
        }
      }
      return -1; // Not found
    } catch (e) {
      print('❌ Error getting user rank: $e');
      return -1;
    }
  }

  // ===== SOCIAL FEED MANAGEMENT =====

  /// Post to social feed
  static Future<void> createSocialPost(SocialPost post) async {
    try {
      await _firestore.collection('social_posts').add(post.toJson());

      print('✅ Created social post');
    } catch (e) {
      print('❌ Error creating social post: $e');
      rethrow;
    }
  }

  /// Get social feed posts
  static Future<List<SocialPost>> getSocialFeed({int limit = 20}) async {
    try {
      final query =
          await _firestore
              .collection('social_posts')
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

      return query.docs
          .map((doc) => SocialPost.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('❌ Error getting social feed: $e');
      return [];
    }
  }

  /// Like/unlike a post
  static Future<void> togglePostLike(String postId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('social_posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (postDoc.exists) {
          final data = postDoc.data()!;
          final likes = List<String>.from(data['likes'] ?? []);

          if (likes.contains(userId)) {
            likes.remove(userId);
          } else {
            likes.add(userId);
          }

          transaction.update(postRef, {'likes': likes});
        }
      });
    } catch (e) {
      print('❌ Error toggling post like: $e');
    }
  }

  /// Add comment to post
  static Future<void> addComment(
    String postId,
    String userId,
    String username,
    String content,
  ) async {
    try {
      final comment = {
        'userId': userId,
        'username': username,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('social_posts')
          .doc(postId)
          .collection('comments')
          .add(comment);
    } catch (e) {
      print('❌ Error adding comment: $e');
    }
  }

  // ===== UTILITY METHODS =====

  /// Auto-post achievement unlock to social feed
  static Future<void> postAchievementUnlock(
    String userId,
    String achievementId,
  ) async {
    try {
      // Get user profile
      final profileDoc =
          await _firestore.collection('gamification_profile').doc(userId).get();

      if (!profileDoc.exists) return;

      final username = profileDoc.data()!['username'] ?? 'User';
      final achievement = AchievementService.getAchievementById(achievementId);

      if (achievement != null) {
        final post = SocialPost(
          id: '',
          userId: userId,
          username: username,
          content:
              'Just unlocked the "${achievement.title}" achievement! ${achievement.description}',
          timestamp: DateTime.now(),
          likes: [],
          postType: PostType.achievement,
          workoutData: null,
          achievementData: {
            'achievementId': achievementId,
            'title': achievement.title,
            'description': achievement.description,
            'tier': achievement.badgeType.toString(),
          },
        );

        await createSocialPost(post);
      }
    } catch (e) {
      print('❌ Error posting achievement unlock: $e');
    }
  }

  /// Auto-post workout completion
  static Future<void> postWorkoutCompletion({
    required String exerciseType,
    required int repCount,
    required double formScore,
    required int durationMinutes,
    required int xpEarned,
  }) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // Get user profile
      final profileDoc =
          await _firestore.collection('gamification_profile').doc(userId).get();

      if (!profileDoc.exists) return;

      final username = profileDoc.data()!['username'] ?? 'User';

      final post = SocialPost(
        id: '',
        userId: userId,
        username: username,
        content: 'Just completed a $exerciseType workout! 💪',
        timestamp: DateTime.now(),
        likes: [],
        postType: PostType.workout,
        workoutData: {
          'exerciseType': exerciseType,
          'repCount': repCount,
          'formScore': formScore,
          'duration': durationMinutes,
          'xpEarned': xpEarned,
        },
        achievementData: null,
      );

      await createSocialPost(post);
    } catch (e) {
      print('❌ Error posting workout completion: $e');
    }
  }

  /// Calculate estimated calories burned based on exercise and duration
  static int _calculateCaloriesBurned(
    int durationMinutes,
    String exerciseType,
  ) {
    // Simple estimation using METs (Metabolic Equivalent of Task)
    double mets;
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
      case 'arm circling':
        mets = 3.0; // Light resistance training
        break;
      case 'push up':
      case 'pushup':
        mets = 4.0; // Moderate resistance training
        break;
      case 'shoulder press':
        mets = 3.5; // Moderate resistance training
        break;
      case 'squat':
        mets = 5.0; // Vigorous resistance training
        break;
      default:
        mets = 4.0; // Default moderate exercise
    }

    // Estimation: METs * weight(kg) * duration(hours)
    // Using average weight of 70kg for calculation
    final weightKg = 70;
    final durationHours = durationMinutes / 60.0;
    final caloriesBurned = (mets * weightKg * durationHours).round();

    return caloriesBurned;
  }
}
