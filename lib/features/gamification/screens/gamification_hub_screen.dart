// lib/features/gamification/screens/gamification_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gamification_models.dart';
import '../services/scoring_service.dart';
import '../services/achievement_service.dart';
import '../services/leaderboard_service.dart';
import '../services/gamification_firebase_service.dart';
import 'leaderboard_screen.dart';
import 'social_feed_screen.dart';
import 'achievements_screen.dart';
import 'progress_screen.dart';

class GamificationHubScreen extends StatefulWidget {
  const GamificationHubScreen({Key? key}) : super(key: key);

  @override
  State<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends State<GamificationHubScreen> {
  UserStats? _userStats;
  List<Achievement> _recentAchievements = [];
  List<LeaderboardEntry> _topUsers = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user ID from Firebase Auth
      _currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (_currentUserId == null) {
        print('❌ No user logged in to Firebase');
        setState(() => _isLoading = false);
        return;
      }

      print('🔍 Loading gamification data for user: $_currentUserId');

      // Load real user stats from Firebase
      final userStats = await GamificationFirebaseService.getUserStats(
        _currentUserId!,
      );

      if (userStats != null) {
        _userStats = userStats;
        print(
          '✅ Loaded real user stats: Level ${userStats.level}, XP ${userStats.totalXP}',
        );
      } else {
        print('⚠️ No user stats found, initializing...');
        // Initialize user stats if they don't exist
        final user = FirebaseAuth.instance.currentUser;
        final userName = user?.email ?? 'User';
        await GamificationFirebaseService.initializeUserStats(
          _currentUserId!,
          userName,
        );
        final newStats = await GamificationFirebaseService.getUserStats(
          _currentUserId!,
        );
        _userStats = newStats ?? UserStats.empty(_currentUserId!);
      }

      // Load recent achievements
      _recentAchievements =
          AchievementService.getUnlockedAchievements(
            _userStats!.unlockedAchievements,
          ).take(3).toList();

      // Load top leaderboard users
      final leaderboard = await LeaderboardService.getGlobalLeaderboard();
      _topUsers = leaderboard.take(3).toList();
    } catch (e) {
      print('Error loading gamification data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGamificationData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User progress card
              _buildUserProgressCard(),
              const SizedBox(height: 20),

              // Quick stats row
              _buildQuickStatsRow(),
              const SizedBox(height: 20),

              // Navigation cards
              _buildNavigationCards(),
              const SizedBox(height: 20),

              // Recent achievements
              if (_recentAchievements.isNotEmpty) ...[
                _buildSectionHeader('Recent Achievements', Icons.emoji_events),
                const SizedBox(height: 12),
                _buildRecentAchievements(),
                const SizedBox(height: 20),
              ],

              // Top performers
              _buildSectionHeader('Top Performers', Icons.leaderboard),
              const SizedBox(height: 12),
              _buildTopPerformers(),
              const SizedBox(height: 20),

              // Motivation section
              _buildMotivationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProgressCard() {
    if (_userStats == null) return const SizedBox.shrink();

    final levelProgress = ScoringService.getLevelProgress(_userStats!.totalXP);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    'L${_userStats!.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_userStats!.totalXP} XP',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '🔥 ${_userStats!.currentStreak}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'day streak',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar for next level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${levelProgress['currentLevel']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Level ${levelProgress['currentLevel'] + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: levelProgress['progressPercentage'] / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${levelProgress['xpNeededForNext']} XP to next level',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    if (_userStats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Workouts',
            '${_userStats!.totalWorkouts}',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Reps',
            '${_userStats!.totalReps}',
            Icons.repeat,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Form',
            '${_userStats!.averageFormScore.toStringAsFixed(1)}%',
            Icons.star,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio:
          1.3, // Increased aspect ratio for better text visibility
      children: [
        _buildNavigationCard(
          'Leaderboard',
          'Compete with others',
          Icons.leaderboard,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          ),
        ),
        _buildNavigationCard(
          'Community',
          'Share your journey',
          Icons.people,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SocialFeedScreen()),
          ),
        ),
        _buildNavigationCard(
          'Achievements',
          'View your badges',
          Icons.emoji_events,
          Colors.amber,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
          ),
        ),
        _buildNavigationCard(
          'Progress',
          'Track your stats',
          Icons.trending_up,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProgressScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ), // Increased padding for better visibility
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32), // Increased icon size
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow 2 lines for subtitle
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentAchievements.length,
        itemBuilder: (context, index) {
          final achievement = _recentAchievements[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              _topUsers.asMap().entries.map((entry) {
                int index = entry.key;
                LeaderboardEntry user = entry.value;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index + 1),
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text('Level ${user.level}'),
                  trailing: Text(
                    '${user.totalXP} XP',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMotivationSection() {
    if (_userStats == null) return const SizedBox.shrink();

    String motivationMessage = ScoringService.getMotivationMessage(
      formScore: _userStats!.averageFormScore,
      streak: _userStats!.currentStreak,
      xpEarned: 150, // Mock recent XP
      hasNewAchievement: false,
    );

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.psychology, color: Colors.blue[600], size: 32),
            const SizedBox(height: 8),
            const Text(
              'Keep Going!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              motivationMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[800]!;
      default:
        return Colors.blue;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to auth wrapper which will show login screen
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
