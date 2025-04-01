// file: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../models/achievement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  List<WorkoutSession> _recentWorkouts = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      // Load user profile
      final profile = await firebaseService.getUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
        });
      }

      // Load recent workouts
      final workouts = await firebaseService.getWorkoutHistory();
      setState(() {
        _recentWorkouts = workouts.take(5).toList(); // Get last 5 workouts
      });

      // Load achievements (we'll need to add this method to FirebaseService)
      // For now, using placeholder data
      setState(() {
        _achievements = [
          Achievement(
            id: 'first_workout',
            title: 'First Workout',
            description: 'Complete your first workout',
            iconUrl: 'assets/icons/first_workout.png',
            isUnlocked: true,
            unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Achievement(
            id: 'streak_3',
            title: '3 Day Streak',
            description: 'Work out for 3 consecutive days',
            iconUrl: 'assets/icons/streak_3.png',
            isUnlocked: false,
          ),
        ];
      });
    } catch (e) {
      print('Error loading user data: $e');
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading your data. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FITGEN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to start workout screen
          _showWorkoutOptionsDialog();
        },
        label: const Text('Start Workout'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildWorkoutsTab();
      case 2:
        return _buildProgressTab();
      case 3:
        return _buildAchievementsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // Stats summary
          _buildStatsSummary(),
          const SizedBox(height: 24),

          // Recent workouts
          const Text(
            'Recent Workouts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _recentWorkouts.isEmpty
              ? _buildEmptyWorkoutsCard()
              : Column(
                children:
                    _recentWorkouts
                        .map((workout) => _buildWorkoutCard(workout))
                        .toList(),
              ),
          const SizedBox(height: 24),

          // Latest achievements
          const Text(
            'Recent Achievements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildAchievementsRow(),
          const SizedBox(height: 80), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final greeting = _getGreeting();
    final name = _userProfile?.name.split(' ').first ?? 'there';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $name!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getMotivationalMessage(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to start workout screen
                _showWorkoutOptionsDialog();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
              child: const Text('START WORKOUT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.calendar_today,
          title: 'Workouts',
          value: _userProfile?.totalWorkouts.toString() ?? '0',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.local_fire_department,
          title: 'Calories',
          value: _userProfile?.totalCaloriesBurned.toString() ?? '0',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.timer,
          title: 'Minutes',
          value: _userProfile?.totalWorkoutMinutes.toString() ?? '0',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWorkoutsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No workouts yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first workout to track your progress!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutSession workout) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _getWorkoutTypeIcon(workout.workoutType),
        title: Text(
          '${workout.workoutType.toUpperCase()} Workout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${workout.exercises.length} exercises • ${workout.durationMinutes} min • ${workout.caloriesBurned} cal',
        ),
        trailing: Text(
          _formatDate(workout.timestamp),
          style: TextStyle(color: Colors.grey[600]),
        ),
        onTap: () {
          // Navigate to workout details screen
        },
      ),
    );
  }

  Widget _buildAchievementsRow() {
    return SizedBox(
      height: 120,
      child:
          _achievements.isEmpty
              ? const Center(
                child: Text('No achievements yet. Start working out!'),
              )
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final achievement = _achievements[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 32,
                            color:
                                achievement.isUnlocked
                                    ? Colors.amber
                                    : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievement.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            achievement.isUnlocked ? 'Unlocked' : 'Locked',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  achievement.isUnlocked
                                      ? Colors.green
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildWorkoutsTab() {
    // This would normally show a list of available workouts
    return const Center(child: Text('Workouts tab - Coming soon'));
  }

  Widget _buildProgressTab() {
    // This would show progress charts and stats
    return const Center(child: Text('Progress tab - Coming soon'));
  }

  Widget _buildAchievementsTab() {
    // This would show all achievements
    return const Center(child: Text('Achievements tab - Coming soon'));
  }

  Widget _getWorkoutTypeIcon(String workoutType) {
    IconData iconData;
    Color color;

    switch (workoutType.toLowerCase()) {
      case 'strength':
        iconData = Icons.fitness_center;
        color = Colors.blue;
        break;
      case 'cardio':
        iconData = Icons.directions_run;
        color = Colors.red;
        break;
      case 'flexibility':
        iconData = Icons.self_improvement;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.sports_gymnastics;
        color = Colors.orange;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getMotivationalMessage() {
    final messages = [
      'Ready for another great workout?',
      'Time to crush your fitness goals!',
      'Today is a perfect day to get stronger!',
      'Let\'s build those healthy habits!',
      'Your future self will thank you for today\'s effort!',
    ];

    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showWorkoutOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start a Workout'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWorkoutOption(
                  title: 'Strength Training',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to strength workout screen
                  },
                ),
                _buildWorkoutOption(
                  title: 'Cardio',
                  icon: Icons.directions_run,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to cardio workout screen
                  },
                ),
                _buildWorkoutOption(
                  title: 'Flexibility',
                  icon: Icons.self_improvement,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to flexibility workout screen
                  },
                ),
                _buildWorkoutOption(
                  title: 'Custom Workout',
                  icon: Icons.add_circle_outline,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to custom workout setup screen
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkoutOption({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
