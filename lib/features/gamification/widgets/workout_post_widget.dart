// lib/features/gamification/widgets/workout_post_widget.dart

import 'package:flutter/material.dart';
import '../models/gamification_models.dart';

class WorkoutPostWidget extends StatelessWidget {
  final WorkoutSession workoutData;

  const WorkoutPostWidget({Key? key, required this.workoutData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout header
          Row(
            children: [
              Icon(
                _getExerciseIcon(workoutData.exerciseType),
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _getExerciseName(workoutData.exerciseType),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${workoutData.xpEarned} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Workout stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Reps',
                  '${workoutData.repsCompleted}',
                  Icons.repeat,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Form Score',
                  '${workoutData.averageFormScore.toStringAsFixed(1)}%',
                  Icons.star,
                  _getFormScoreColor(workoutData.averageFormScore),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Duration',
                  _formatDuration(workoutData.duration),
                  Icons.timer,
                  Colors.green,
                ),
              ),
            ],
          ),

          // Achievement badges (if any)
          if (workoutData.achievementsUnlocked.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Achievements Unlocked:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      workoutData.achievementsUnlocked.map((achievementId) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getAchievementName(achievementId),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(String exerciseType) {
    switch (exerciseType) {
      case 'bicepCurl':
        return Icons.fitness_center;
      case 'squat':
        return Icons.accessibility_new;
      case 'pushup':
        return Icons.sports_gymnastics;
      case 'shoulderPress':
        return Icons.sports_handball;
      case 'armCircling':
        return Icons.rotate_right;
      default:
        return Icons.sports;
    }
  }

  String _getExerciseName(String exerciseType) {
    switch (exerciseType) {
      case 'bicepCurl':
        return 'Bicep Curls';
      case 'squat':
        return 'Squats';
      case 'pushup':
        return 'Push-ups';
      case 'shoulderPress':
        return 'Shoulder Press';
      case 'armCircling':
        return 'Arm Circling';
      default:
        return 'Workout';
    }
  }

  Color _getFormScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.yellow[700]!;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _getAchievementName(String achievementId) {
    switch (achievementId) {
      case 'first_workout':
        return 'First Steps';
      case 'perfect_form_workout':
        return 'Form Master';
      case 'rep_master_50':
        return 'Rep Master';
      case 'rep_master_100':
        return 'Century Club';
      case 'workout_streak_3':
        return 'Getting Started';
      case 'workout_streak_7':
        return 'Week Warrior';
      case 'workout_streak_30':
        return 'Consistency King';
      default:
        return 'Achievement';
    }
  }
}
