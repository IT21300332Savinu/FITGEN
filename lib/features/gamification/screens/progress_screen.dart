// lib/features/gamification/screens/progress_screen.dart

import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/scoring_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock user data - in a real app, this would come from your database
  final UserStats _userStats = UserStats(
    userId: "user123",
    totalXP: 8750,
    level: 8,
    totalWorkouts: 47,
    totalReps: 1250,
    totalCalories: 1800,
    totalMinutes: 420,
    currentStreak: 5,
    longestStreak: 12,
    averageFormScore: 87.5,
    lastWorkoutDate: DateTime.now().subtract(const Duration(hours: 2)),
    exerciseCount: {
      'bicepCurl': 15,
      'squat': 12,
      'pushup': 10,
      'shoulderPress': 6,
      'armCircling': 4,
    },
    unlockedAchievements: [
      'first_workout',
      'workout_streak_3',
      'total_workouts_10',
      'perfect_form_workout',
      'rep_master_50',
    ],
  );

  // Mock historical data
  final List<Map<String, dynamic>> _weeklyWorkouts = [
    {'week': 'Week 1', 'workouts': 3, 'xp': 450},
    {'week': 'Week 2', 'workouts': 4, 'xp': 620},
    {'week': 'Week 3', 'workouts': 5, 'xp': 750},
    {'week': 'Week 4', 'workouts': 6, 'xp': 890},
    {'week': 'Week 5', 'workouts': 4, 'xp': 580},
    {'week': 'Week 6', 'workouts': 7, 'xp': 1020},
    {'week': 'Week 7', 'workouts': 5, 'xp': 725},
  ];

  final List<Map<String, dynamic>> _formScoreHistory = [
    {'date': 'Mon', 'score': 85.0},
    {'date': 'Tue', 'score': 88.5},
    {'date': 'Wed', 'score': 92.0},
    {'date': 'Thu', 'score': 89.5},
    {'date': 'Fri', 'score': 94.0},
    {'date': 'Sat', 'score': 87.0},
    {'date': 'Sun', 'score': 91.5},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up), text: 'Overview'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Workouts'),
            Tab(icon: Icon(Icons.star), text: 'Form Score'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildWorkoutsTab(),
          _buildFormScoreTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current stats cards
          _buildCurrentStatsCards(),
          const SizedBox(height: 20),

          // XP Progress
          _buildXPProgressSection(),
          const SizedBox(height: 20),

          // Exercise breakdown
          _buildExerciseBreakdown(),
          const SizedBox(height: 20),

          // Recent achievements
          _buildRecentAchievements(),
        ],
      ),
    );
  }

  Widget _buildCurrentStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Level',
              '${_userStats.level}',
              Icons.emoji_events,
              Colors.amber,
              subtitle: '${_userStats.totalXP} XP',
            ),
            _buildStatCard(
              'Current Streak',
              '${_userStats.currentStreak}',
              Icons.local_fire_department,
              Colors.orange,
              subtitle: 'days',
            ),
            _buildStatCard(
              'Total Workouts',
              '${_userStats.totalWorkouts}',
              Icons.fitness_center,
              Colors.blue,
              subtitle: 'completed',
            ),
            _buildStatCard(
              'Avg Form Score',
              '${_userStats.averageFormScore.toStringAsFixed(1)}%',
              Icons.star,
              Colors.green,
              subtitle: 'accuracy',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPProgressSection() {
    final levelProgress = ScoringService.getLevelProgress(_userStats.totalXP);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Level Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    'L${levelProgress['currentLevel']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${levelProgress['currentLevel']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Level ${levelProgress['currentLevel'] + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: levelProgress['progressPercentage'] / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${levelProgress['xpNeededForNext']} XP to next level',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseBreakdown() {
    final exercises = _userStats.exerciseCount.entries.toList();
    exercises.sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercise Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...exercises.map((entry) {
              final exerciseName = _formatExerciseName(entry.key);
              final count = entry.value;
              final maxCount = exercises.first.value;
              final percentage = count / maxCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          exerciseName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$count sessions',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getExerciseColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_userStats.unlockedAchievements.length} achievements unlocked',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to achievements screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Workout Progress',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Workout summary cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'This Week',
                '${_weeklyWorkouts.last['workouts']}',
                Icons.fitness_center,
                Colors.blue,
                subtitle: 'workouts',
              ),
              _buildStatCard(
                'Weekly XP',
                '${_weeklyWorkouts.last['xp']}',
                Icons.star,
                Colors.green,
                subtitle: 'points earned',
              ),
              _buildStatCard(
                'Best Week',
                '${_weeklyWorkouts.map((w) => w['workouts']).reduce((a, b) => a > b ? a : b)}',
                Icons.trending_up,
                Colors.purple,
                subtitle: 'workouts',
              ),
              _buildStatCard(
                'Total Reps',
                '${_userStats.totalReps}',
                Icons.repeat,
                Colors.orange,
                subtitle: 'all time',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly workout history
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._weeklyWorkouts.map((week) {
                    final workouts = week['workouts'] as int;
                    final xp = week['xp'] as int;
                    final maxWorkouts = _weeklyWorkouts.map((w) => w['workouts'] as int).reduce((a, b) => a > b ? a : b);
                    final progress = workouts / maxWorkouts;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                week['week'],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '$workouts workouts • $xp XP',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 0.8 ? Colors.green : 
                              progress > 0.6 ? Colors.amber : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormScoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form Score Analysis',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Average form score card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Average Form Score',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getFormScoreColor(_userStats.averageFormScore).withOpacity(0.2),
                      border: Border.all(
                        color: _getFormScoreColor(_userStats.averageFormScore),
                        width: 8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_userStats.averageFormScore.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getFormScoreLabel(_userStats.averageFormScore),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getFormScoreColor(_userStats.averageFormScore),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Daily form score this week
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Form Score (This Week)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._formScoreHistory.map((day) {
                    final score = day['score'] as double;
                    final progress = score / 100;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                day['date'],
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${score.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getFormScoreColor(score),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getFormScoreColor(score),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Form improvement tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Improvement Tips',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem(
                    '🎯',
                    'Focus on Precision',
                    'Slow down your movements and focus on proper form over speed.',
                  ),
                  _buildTipItem(
                    '📱',
                    'Use Camera Feedback',
                    'Pay attention to the AI form analysis during your workouts.',
                  ),
                  _buildTipItem(
                    '💪',
                    'Practice Makes Perfect',
                    'Regular practice will improve your form score over time.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatExerciseName(String exerciseKey) {
    switch (exerciseKey) {
      case 'bicepCurl':
        return 'Bicep Curl';
      case 'shoulderPress':
        return 'Shoulder Press';
      case 'armCircling':
        return 'Arm Circling';
      default:
        return exerciseKey.toUpperCase();
    }
  }

  Color _getExerciseColor(String exerciseKey) {
    switch (exerciseKey) {
      case 'bicepCurl':
        return Colors.blue;
      case 'squat':
        return Colors.green;
      case 'pushup':
        return Colors.red;
      case 'shoulderPress':
        return Colors.purple;
      case 'armCircling':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getFormScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.amber;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  String _getFormScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Fair';
    return 'Needs Improvement';
  }
}