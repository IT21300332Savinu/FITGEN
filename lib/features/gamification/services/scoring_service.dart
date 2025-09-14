// lib/features/gamification/services/scoring_service.dart

import '../models/gamification_models.dart';
import '../../ai_trainer/models/exercise_models.dart';

class ScoringService {
  static const int BASE_XP_PER_REP = 10;
  static const int PERFECT_FORM_BONUS = 5;
  static const int STREAK_MULTIPLIER_BASE = 2;
  static const int FIRST_WORKOUT_BONUS = 50;

  /// Calculate XP earned for a workout session (simplified for Firebase integration)
  static int calculateXP({
    required double formScore,
    required int repCount,
    required String exerciseType,
    required UserStats userStats,
  }) {
    if (repCount <= 0) return 0;

    // Base XP calculation
    int baseXP = repCount * BASE_XP_PER_REP;

    // Exercise difficulty multiplier based on string name
    double difficultyMultiplier = _getExerciseDifficultyMultiplier(exerciseType);

    // Form quality bonus (0-100% form score)
    double formBonus = formScore * PERFECT_FORM_BONUS;

    // Streak bonus (increases XP by 10% per day in streak, max 100% bonus)
    double streakMultiplier = 1.0 + (userStats.currentStreak * 0.1).clamp(0.0, 1.0);

    // First workout bonus
    bool isFirstWorkout = userStats.totalWorkouts == 0;
    double firstWorkoutBonus = isFirstWorkout ? FIRST_WORKOUT_BONUS.toDouble() : 0.0;

    // Calculate total XP
    double totalXP = (baseXP * difficultyMultiplier + formBonus + firstWorkoutBonus) * streakMultiplier;

    return totalXP.round();
  }

  /// Calculate level from total XP
  static int calculateLevel(int totalXP) {
    return (totalXP / 1000).floor() + 1;
  }

  /// Get exercise difficulty multiplier based on exercise name
  static double _getExerciseDifficultyMultiplier(String exerciseType) {
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
      case 'bicepcurl':
      case 'arm circling':
      case 'armcircling':
        return 1.0; // Beginner
      case 'squat':
      case 'pushup':
      case 'push up':
        return 1.5; // Intermediate
      case 'shoulder press':
      case 'shoulderpress':
        return 2.0; // Advanced
      default:
        return 1.0; // Default to beginner
    }
  }

  /// Calculate XP earned for a workout session
  static int calculateWorkoutXP({
    required ExerciseType exerciseType,
    required int repsCompleted,
    required double averageFormScore,
    required Duration workoutDuration,
    required int currentStreak,
    required bool isFirstWorkout,
  }) {
    if (repsCompleted <= 0) return 0;

    // Base XP calculation
    int baseXP = repsCompleted * BASE_XP_PER_REP;

    // Exercise difficulty multiplier
    ExerciseDifficulty difficulty = _getExerciseDifficulty(exerciseType);
    double difficultyMultiplier = difficulty.multiplier;

    // Form quality bonus (0-100% form score)
    double formBonus = averageFormScore * PERFECT_FORM_BONUS;

    // Streak bonus (increases XP by 10% per day in streak, max 100% bonus)
    double streakMultiplier = 1.0 + (currentStreak * 0.1).clamp(0.0, 1.0);

    // Duration bonus for longer workouts (bonus for 5+ minute workouts)
    double durationBonus = workoutDuration.inMinutes >= 5 ? 
        (workoutDuration.inMinutes * 2).toDouble() : 0.0;

    // Calculate total XP
    double totalXP = (baseXP * difficultyMultiplier + formBonus + durationBonus) * streakMultiplier;

    // First workout bonus
    if (isFirstWorkout) {
      totalXP += FIRST_WORKOUT_BONUS;
    }

    return totalXP.round();
  }

  /// Get exercise difficulty based on exercise type
  static ExerciseDifficulty _getExerciseDifficulty(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.bicepCurl:
        return ExerciseDifficulty.beginner;
      case ExerciseType.squat:
        return ExerciseDifficulty.intermediate;
      case ExerciseType.pushup:
        return ExerciseDifficulty.intermediate;
      case ExerciseType.shoulderPress:
        return ExerciseDifficulty.advanced;
      case ExerciseType.armCircling:
        return ExerciseDifficulty.beginner;
    }
  }

  /// Calculate streak based on workout history
  static int calculateStreak(List<DateTime> workoutDates) {
    if (workoutDates.isEmpty) return 0;

    workoutDates.sort((a, b) => b.compareTo(a)); // Sort descending
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    int streak = 0;
    DateTime checkDate = today;

    for (DateTime workoutDate in workoutDates) {
      DateTime workoutDay = DateTime(workoutDate.year, workoutDate.month, workoutDate.day);
      
      if (workoutDay == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (workoutDay.isBefore(checkDate)) {
        // Gap in workout dates, streak broken
        break;
      }
      // If workout is in the future, skip it
    }

    return streak;
  }

  /// Calculate form score based on exercise metrics
  static double calculateFormScore({
    required double formQuality,
    required int goodReps,
    required int totalReps,
    required List<double> angleAccuracy,
  }) {
    if (totalReps == 0) return 0.0;

    // Base form score from form quality (0.0 to 1.0)
    double baseScore = formQuality.clamp(0.0, 1.0);

    // Good reps ratio bonus
    double goodRepsRatio = goodReps / totalReps;
    
    // Angle accuracy (average of all angle measurements)
    double avgAngleAccuracy = angleAccuracy.isNotEmpty ? 
        angleAccuracy.reduce((a, b) => a + b) / angleAccuracy.length : 0.0;

    // Combined score (weighted average)
    double combinedScore = (baseScore * 0.5) + 
                          (goodRepsRatio * 0.3) + 
                          (avgAngleAccuracy * 0.2);

    return (combinedScore * 100).clamp(0.0, 100.0);
  }

  /// Calculate performance rating
  static String getPerformanceRating(double formScore) {
    if (formScore >= 95) return "Perfect";
    if (formScore >= 90) return "Excellent";
    if (formScore >= 80) return "Great";
    if (formScore >= 70) return "Good";
    if (formScore >= 60) return "Fair";
    return "Needs Improvement";
  }

  /// Calculate weekly XP from workout sessions
  static int calculateWeeklyXP(List<WorkoutSession> sessions) {
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return sessions
        .where((session) => session.startTime.isAfter(weekStart))
        .fold(0, (total, session) => total + session.xpEarned);
  }

  /// Calculate monthly XP from workout sessions
  static int calculateMonthlyXP(List<WorkoutSession> sessions) {
    DateTime now = DateTime.now();
    DateTime monthStart = DateTime(now.year, now.month, 1);
    
    return sessions
        .where((session) => session.startTime.isAfter(monthStart))
        .fold(0, (total, session) => total + session.xpEarned);
  }

  /// Generate workout summary with scoring details
  static Map<String, dynamic> generateWorkoutSummary({
    required ExerciseType exerciseType,
    required int repsCompleted,
    required double averageFormScore,
    required Duration workoutDuration,
    required int xpEarned,
    required int currentStreak,
    required List<String> achievementsUnlocked,
  }) {
    return {
      'exerciseType': exerciseType.name,
      'repsCompleted': repsCompleted,
      'formScore': averageFormScore.toStringAsFixed(1),
      'formRating': getPerformanceRating(averageFormScore),
      'duration': '${workoutDuration.inMinutes}m ${workoutDuration.inSeconds % 60}s',
      'xpEarned': xpEarned,
      'currentStreak': currentStreak,
      'achievementsUnlocked': achievementsUnlocked,
      'difficulty': _getExerciseDifficulty(exerciseType).name,
    };
  }

  /// Calculate progress towards next level
  static Map<String, dynamic> getLevelProgress(int currentXP) {
    int currentLevel = UserStats.calculateLevel(currentXP);
    int currentLevelXP = (currentLevel - 1) * 1000;
    int nextLevelXP = currentLevel * 1000;
    int xpInCurrentLevel = currentXP - currentLevelXP;
    int xpNeededForNext = nextLevelXP - currentXP;
    double progressPercentage = (xpInCurrentLevel / 1000) * 100;

    return {
      'currentLevel': currentLevel,
      'xpInCurrentLevel': xpInCurrentLevel,
      'xpNeededForNext': xpNeededForNext,
      'progressPercentage': progressPercentage.clamp(0.0, 100.0),
      'totalXPForNextLevel': 1000,
    };
  }

  /// Calculate motivation message based on performance
  static String getMotivationMessage({
    required double formScore,
    required int streak,
    required int xpEarned,
    required bool hasNewAchievement,
  }) {
    if (hasNewAchievement) {
      return "🏆 Achievement Unlocked! You're crushing it!";
    }
    
    if (formScore >= 95) {
      return "🔥 Perfect form! You're a fitness machine!";
    } else if (formScore >= 90) {
      return "💪 Excellent workout! Keep up the great form!";
    } else if (formScore >= 80) {
      return "⭐ Great job! Your technique is improving!";
    }
    
    if (streak >= 7) {
      return "🚀 Amazing ${streak}-day streak! You're unstoppable!";
    } else if (streak >= 3) {
      return "🔥 ${streak} days in a row! Building great habits!";
    }
    
    if (xpEarned >= 200) {
      return "💯 Massive XP gain! You earned ${xpEarned} points!";
    } else if (xpEarned >= 100) {
      return "⚡ Great workout! ${xpEarned} XP earned!";
    }
    
    return "🎯 Good work! Every rep counts towards your goals!";
  }

  /// Calculate bonus XP for special achievements
  static int calculateBonusXP({
    required String achievementType,
    required Map<String, dynamic> data,
  }) {
    switch (achievementType) {
      case 'perfect_workout':
        return 100;
      case 'week_streak':
        int weeks = data['weeks'] ?? 1;
        return weeks * 50;
      case 'personal_record':
        return 75;
      case 'consistency_master':
        return 200;
      case 'form_perfectionist':
        return 150;
      default:
        return 25;
    }
  }
}