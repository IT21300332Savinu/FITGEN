// lib/features/gamification/services/leaderboard_service.dart

import '../models/gamification_models.dart';
import 'gamification_firebase_service.dart';

class LeaderboardService {
  
  /// Get global leaderboard (all-time XP)
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    try {
      return await GamificationFirebaseService.getLeaderboard(
        type: LeaderboardType.allTime,
        limit: 50,
      );
    } catch (e) {
      print('Error getting global leaderboard: $e');
      return [];
    }
  }

  /// Get weekly leaderboard
  static Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    try {
      return await GamificationFirebaseService.getLeaderboard(
        type: LeaderboardType.weekly,
        limit: 50,
      );
    } catch (e) {
      print('Error getting weekly leaderboard: $e');
      return [];
    }
  }

  /// Get monthly leaderboard
  static Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async {
    try {
      return await GamificationFirebaseService.getLeaderboard(
        type: LeaderboardType.monthly,
        limit: 50,
      );
    } catch (e) {
      print('Error getting monthly leaderboard: $e');
      return [];
    }
  }

  /// Get friends leaderboard
  static Future<List<LeaderboardEntry>> getFriendsLeaderboard(String userId) async {
    try {
      // For now, return all users as "friends" - in a real app, you'd have a friends system
      final globalLeaderboard = await GamificationFirebaseService.getLeaderboard(
        type: LeaderboardType.weekly,
        limit: 20,
      );
      
      // Filter to show only current user and simulated friends
      return globalLeaderboard.where((entry) => 
        entry.userId == userId || 
        globalLeaderboard.indexOf(entry) < 10 // Show top 10 as "friends"
      ).toList();
    } catch (e) {
      print('Error getting friends leaderboard: $e');
      return [];
    }
  }

  /// Get user's current ranking in global leaderboard
  static Future<int> getUserGlobalRank(String userId) async {
    try {
      final globalLeaderboard = await getGlobalLeaderboard();
      
      for (int i = 0; i < globalLeaderboard.length; i++) {
        if (globalLeaderboard[i].userId == userId) {
          return i + 1;
        }
      }
      
      return -1; // User not found
    } catch (e) {
      print('Error getting user global rank: $e');
      return -1;
    }
  }

  /// Get user's position change compared to previous period
  static Future<Map<String, int>> getUserRankChanges(String userId) async {
    try {
      // In a real app, this would compare with previous rankings stored in Firebase
      // For now, return mock data
      return {
        'weeklyChange': 2, // Moved up 2 positions
        'monthlyChange': -1, // Moved down 1 position
        'globalChange': 0, // No change
      };
    } catch (e) {
      print('Error getting user rank changes: $e');
      return {
        'weeklyChange': 0,
        'monthlyChange': 0,
        'globalChange': 0,
      };
    }
  }

  /// Get leaderboard statistics
  static Future<Map<String, dynamic>> getLeaderboardStats() async {
    try {
      final globalLeaderboard = await getGlobalLeaderboard();
      
      if (globalLeaderboard.isEmpty) {
        return {
          'totalUsers': 0,
          'activeThisWeek': 0,
          'activeThisMonth': 0,
          'averageXP': 0,
          'topUserXP': 0,
        };
      }

      final totalXP = globalLeaderboard.fold<int>(0, (sum, entry) => sum + entry.totalXP);
      
      return {
        'totalUsers': globalLeaderboard.length,
        'activeThisWeek': globalLeaderboard.length, // All users in leaderboard are active
        'activeThisMonth': globalLeaderboard.length,
        'averageXP': totalXP ~/ globalLeaderboard.length,
        'topUserXP': globalLeaderboard.isNotEmpty ? globalLeaderboard.first.totalXP : 0,
      };
    } catch (e) {
      print('Error getting leaderboard stats: $e');
      return {
        'totalUsers': 0,
        'activeThisWeek': 0,
        'activeThisMonth': 0,
        'averageXP': 0,
        'topUserXP': 0,
      };
    }
  }

  /// Search for users in leaderboard
  static Future<List<LeaderboardEntry>> searchUsers(String query) async {
    try {
      final allUsers = await getGlobalLeaderboard();
      
      return allUsers
          .where((user) => user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get nearby users in ranking (users ranked around current user)
  static Future<List<LeaderboardEntry>> getNearbyUsers(String userId, {int range = 3}) async {
    try {
      final globalLeaderboard = await getGlobalLeaderboard();
      
      int userIndex = globalLeaderboard.indexWhere((user) => user.userId == userId);
      if (userIndex == -1) return [];
      
      int startIndex = (userIndex - range).clamp(0, globalLeaderboard.length - 1);
      int endIndex = (userIndex + range + 1).clamp(0, globalLeaderboard.length);
      
      return globalLeaderboard.sublist(startIndex, endIndex);
    } catch (e) {
      print('Error getting nearby users: $e');
      return [];
    }
  }

  /// Get challenge leaderboard for specific challenge
  static Future<List<LeaderboardEntry>> getChallengeLeaderboard(String challengeId) async {
    try {
      // In a real app, this would fetch challenge-specific leaderboard from Firebase
      // For now, return a subset of global leaderboard
      final globalLeaderboard = await getGlobalLeaderboard();
      return globalLeaderboard.take(10).toList();
    } catch (e) {
      print('Error getting challenge leaderboard: $e');
      return [];
    }
  }
}