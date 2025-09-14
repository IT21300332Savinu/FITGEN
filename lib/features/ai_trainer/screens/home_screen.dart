import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_screen.dart';
import 'exercise_instruction_screen.dart';
import '../../gamification/screens/gamification_hub_screen.dart';
import 'login_screen.dart';
import '../../gamification/services/gamification_firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User'; // You can load this from your user profile
  int _totalWorkouts = 0;
  int _totalCalories = 0;
  int _totalMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning to this screen
    _loadUserData();
  }

  void _startExercise(String exerciseName, String workoutType) {
    debugPrint(
      '🏠 Home Screen: Starting exercise: $exerciseName, type: $workoutType',
    );
    try {
      // Check if it's any AI exercise
      if (exerciseName.contains('(AI)')) {
        debugPrint(
          '🏠 Home Screen: This is an AI exercise, proceeding to instruction screen',
        );
        // Extract the exercise name without "(AI)" suffix
        String cleanExerciseName = exerciseName.replaceAll(' (AI)', '');
        debugPrint('🏠 Home Screen: Clean exercise name: $cleanExerciseName');

        // Navigate to instruction screen first
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ExerciseInstructionScreen(
                  exerciseType: cleanExerciseName,
                  onStartWorkout: () {
                    // Close instruction screen and go to workout
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WorkoutScreen(
                              exerciseName: cleanExerciseName,
                              workoutType: 'strength',
                            ),
                      ),
                    ).then((result) {
                      // Handle result when returning from workout screen
                      if (result != null && result is Map<String, dynamic>) {
                        if (result['completed'] == true) {
                          final repCount = result['repCount'] ?? 0;
                          final duration = result['duration'] ?? 0;
                          final formScore = result['formScore']?.toInt() ?? 0;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$cleanExerciseName Complete! $repCount reps in ${_formatDuration(duration)} with $formScore% form',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 4),
                            ),
                          );

                          // Refresh data after workout
                          if (mounted) {
                            _loadUserData();
                          }
                        }
                      }
                    });
                  },
                ),
          ),
        );
        return;
      }

      // Handle other exercises
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting $exerciseName workout...'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error starting exercise: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSignout() async {
    try {
      // Get current user info for confirmation
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.email ?? 'User';

      // Show confirmation dialog with user info
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign Out'),
            content: Text(
              'Are you sure you want to sign out from "$userName"?\n\nYou can log back in anytime with your account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sign Out'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        // Show signing out message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signing out...'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Sign out from Firebase Auth
        await FirebaseAuth.instance.signOut();

        debugPrint('👋 User signed out successfully');

        // Navigate back to login screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false, // Remove all previous routes
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadUserData() async {
    debugPrint('🔍 Loading user data...');

    try {
      // Load user from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final userName = user?.email ?? 'User';

      debugPrint('🆔 Firebase Auth User - ID: $userId, Email: $userName');

      if (userId != null) {
        debugPrint('📊 Loading Firebase stats for user: $userId');

        // Always fetch fresh data from Firebase
        final userStats = await GamificationFirebaseService.getUserStats(
          userId,
        );

        debugPrint('📈 Firebase Stats Result: ${userStats?.toJson()}');

        if (userStats != null) {
          setState(() {
            _userName = userName;
            _totalWorkouts = userStats.totalWorkouts;
            _totalCalories = userStats.totalCalories;
            _totalMinutes = userStats.totalMinutes;
          });

          debugPrint(
            '✅ UI Updated - $_userName: $_totalWorkouts workouts, $_totalCalories calories, $_totalMinutes minutes',
          );
        } else {
          debugPrint('⚠️ No stats found in Firebase, initializing...');
          // Initialize user stats if they don't exist
          await GamificationFirebaseService.initializeUserStats(
            userId,
            userName,
          );

          setState(() {
            _userName = userName;
            _totalWorkouts = 0;
            _totalCalories = 0;
            _totalMinutes = 0;
          });
        }
      } else {
        debugPrint('⚠️ No user session found, using defaults');
        setState(() {
          _userName = 'User';
          _totalWorkouts = 0;
          _totalCalories = 0;
          _totalMinutes = 0;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading your progress: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _loadUserData(),
            ),
          ),
        );
      }
    }
  }

  void _showWorkoutOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Your Workout'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AI Bicep Curl - Featured
                _buildWorkoutOption(
                  title: 'Bicep Curl (AI Trainer)',
                  subtitle: 'AI-powered form analysis with real-time feedback',
                  icon: Icons.fitness_center,
                  color: Colors.blue,
                  featured: true,
                  onTap: () {
                    Navigator.pop(context);
                    _startExercise('Bicep Curl (AI)', 'strength');
                  },
                ),
                const SizedBox(height: 8),
                // Other workout options
                _buildWorkoutOption(
                  title: 'Strength Training',
                  subtitle: 'Traditional strength exercises',
                  icon: Icons.fitness_center,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelection('strength');
                  },
                ),
                _buildWorkoutOption(
                  title: 'Cardio',
                  subtitle: 'Cardiovascular exercises',
                  icon: Icons.directions_run,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelection('cardio');
                  },
                ),
                _buildWorkoutOption(
                  title: 'Flexibility',
                  subtitle: 'Stretching and mobility',
                  icon: Icons.self_improvement,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseSelection('flexibility');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showExerciseSelection(String workoutType) {
    List<Map<String, String>> exercises = [];

    debugPrint(
      '🏠 Home Screen: Showing exercise selection for workout type: $workoutType',
    );

    if (workoutType == 'strength') {
      exercises = [
        {
          'name': 'Bicep Curl (AI)',
          'description': 'AI-powered bicep curl analysis',
        },
        {
          'name': 'Pushup (AI)',
          'description': 'AI-powered pushup form analysis',
        },
        {'name': 'Squat (AI)', 'description': 'AI-powered squat form analysis'},
        {
          'name': 'Shoulder Press (AI)',
          'description': 'AI-powered shoulder press analysis',
        },
        {
          'name': 'Arm Circling (AI)',
          'description': 'AI-powered arm circling analysis',
        },
        {'name': 'Planks', 'description': 'Core stability'},
      ];
      debugPrint(
        '🏠 Home Screen: Added ${exercises.length} strength exercises',
      );
    } else if (workoutType == 'cardio') {
      exercises = [
        {'name': 'Jumping Jacks', 'description': 'Full body cardio'},
        {'name': 'High Knees', 'description': 'Leg cardio'},
        {'name': 'Burpees', 'description': 'High intensity'},
      ];
    } else if (workoutType == 'flexibility') {
      exercises = [
        {'name': 'Forward Bend', 'description': 'Hamstring stretch'},
        {'name': 'Shoulder Rolls', 'description': 'Upper body mobility'},
        {'name': 'Hip Circles', 'description': 'Hip mobility'},
      ];
    }

    debugPrint('🏠 Home Screen: Total exercises to show: ${exercises.length}');
    for (var exercise in exercises) {
      debugPrint(
        '🏠 Home Screen: - ${exercise['name']}: ${exercise['description']}',
      );
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '${_capitalizeFirst(workoutType)} Exercises (${exercises.length} total)',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    exercises
                        .map(
                          (exercise) => ListTile(
                            title: Text(exercise['name']!),
                            subtitle: Text(exercise['description']!),
                            leading:
                                exercise['name']!.contains('(AI)')
                                    ? Icon(Icons.smart_toy, color: Colors.blue)
                                    : Icon(Icons.fitness_center),
                            onTap: () {
                              debugPrint(
                                '🏠 Home Screen: User selected exercise: ${exercise['name']}',
                              );
                              Navigator.pop(context);
                              _startExercise(exercise['name']!, workoutType);
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
    );
  }

  Widget _buildWorkoutOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool featured = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient:
            featured
                ? LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                : null,
        border: Border.all(
          color: featured ? color : Colors.grey[300]!,
          width: featured ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: featured ? FontWeight.bold : FontWeight.w600,
            fontSize: featured ? 16 : 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: featured ? color : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FITGEN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to gamification hub - where user can see their gaming features
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamificationHubScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'signout') {
                await _handleSignout();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $_userName!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to crush your fitness goals?',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showWorkoutOptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'START WORKOUT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Summary
              const Text(
                'Your Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.fitness_center,
                      title: 'Workouts',
                      value: '$_totalWorkouts',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      title: 'Calories',
                      value: '$_totalCalories',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.timer,
                      title: 'Minutes',
                      value: '$_totalMinutes',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Featured Workout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Featured: AI Trainer',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try our AI-powered bicep curl trainer with real-time form analysis and rep counting!',
                      style: TextStyle(color: Colors.blue[700], fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed:
                          () => _startExercise('Bicep Curl (AI)', 'strength'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Try AI Trainer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Start',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.fitness_center,
                      title: 'Strength',
                      color: Colors.orange,
                      onTap: () => _showExerciseSelection('strength'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.directions_run,
                      title: 'Cardio',
                      color: Colors.red,
                      onTap: () => _showExerciseSelection('cardio'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.self_improvement,
                      title: 'Flexibility',
                      color: Colors.purple,
                      onTap: () => _showExerciseSelection('flexibility'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Health & Nutrition Section
              const Text(
                'Health & Nutrition',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.account_circle,
                      title: 'Create Health Profile',
                      color: Colors.green,
                      onTap: () => _createHealthProfile(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.restaurant_menu,
                      title: 'Diet Plan Maker',
                      color: Colors.teal,
                      onTap: () => _createDietPlan(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Removed floatingActionButton as it was covering the diet plan button
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _createHealthProfile() {
    // Call your teammate's health profile function here
    // Example: HealthProfileService.createProfile(context);
    // Or navigate to their health profile screen:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => YourTeammateHealthProfileScreen(),
    //   ),
    // );

    debugPrint(
      '🏥 Health Profile button tapped - ready for teammate integration',
    );
  }

  void _createDietPlan() {
    // Call your teammate's diet plan function here
    // Example: DietPlanService.createPlan(context);
    // Or navigate to their diet plan screen:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => YourTeammateDietPlanScreen(),
    //   ),
    // );

    debugPrint('🍽️ Diet Plan button tapped - ready for teammate integration');
  }
}
