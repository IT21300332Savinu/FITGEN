// lib/screens/workout_planner.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/mock_wearable_provider.dart';

class WorkoutPlanner extends StatefulWidget {
  @override
  _WorkoutPlannerState createState() => _WorkoutPlannerState();
}

class _WorkoutPlannerState extends State<WorkoutPlanner> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _workoutPlans = [];
  String _selectedDifficulty = 'Moderate';
  String _selectedDuration = '30 min';
  String _selectedFocus = 'Full Body';
  String _userHealthStatus = 'Normal';

  @override
  void initState() {
    super.initState();
    _fetchWorkoutPlans();
  }

  Future<void> _fetchWorkoutPlans() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final authService = Provider.of<AuthService>(context, listen: false);
      final mockWearableProvider = Provider.of<MockWearableProvider>(
        context,
        listen: false,
      );

      // Determine health status based on mock wearable data
      final heartRate = mockWearableProvider.heartRate;
      final bp = mockWearableProvider.bloodPressure;
      final parts = bp.split('/');

      if (parts.length == 2) {
        final systolic = int.tryParse(parts[0]) ?? 0;
        if (systolic > 140) {
          _userHealthStatus = 'Hypertension';
        } else if (heartRate > 100) {
          _userHealthStatus = 'Elevated Heart Rate';
        }
      }

      // Create mock workout plans based on health status
      _createMockWorkoutPlans();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workout plans: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMockWorkoutPlans() {
    // Create mock workout plans based on health status
    List<Map<String, dynamic>> plans = [];

    if (_userHealthStatus == 'Hypertension') {
      plans = [
        {
          'id': '1',
          'title': 'Low-Impact Cardio',
          'description': 'Gentle cardio workout safe for hypertension',
          'difficulty': 'Easy',
          'duration': '20 min',
          'focus': 'Cardio',
          'suitableConditions': ['Hypertension', 'General'],
          'exercises': [
            {
              'name': 'Walking',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Moderate pace walking',
            },
            {
              'name': 'Seated Leg Lifts',
              'duration': '5 min',
              'sets': 3,
              'reps': 10,
              'instructions': 'Sitting on chair, extend leg straight',
            },
            {
              'name': 'Standing Wall Push-ups',
              'duration': '5 min',
              'sets': 3,
              'reps': 10,
              'instructions': 'Push against wall from standing position',
            },
            {
              'name': 'Gentle Stretching',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Full body gentle stretches',
            },
          ],
        },
        {
          'id': '2',
          'title': 'Water Aerobics',
          'description':
              'Low-impact water exercises ideal for blood pressure management',
          'difficulty': 'Moderate',
          'duration': '30 min',
          'focus': 'Full Body',
          'suitableConditions': ['Hypertension', 'Joint Pain'],
          'exercises': [
            {
              'name': 'Water Walking',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Walk through water at chest height',
            },
            {
              'name': 'Arm Curls with Water Resistance',
              'duration': '5 min',
              'sets': 3,
              'reps': 15,
              'instructions': 'Use water resistance for bicep curls',
            },
            {
              'name': 'Leg Lifts in Water',
              'duration': '5 min',
              'sets': 3,
              'reps': 10,
              'instructions':
                  'Standing, lift leg to side using water resistance',
            },
            {
              'name': 'Water Jogging',
              'duration': '10 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Jog in place in deep water with float',
            },
            {
              'name': 'Cool Down',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Gentle movements and stretching',
            },
          ],
        },
      ];
    } else if (_userHealthStatus == 'Elevated Heart Rate') {
      plans = [
        {
          'id': '3',
          'title': 'Recovery Focus',
          'description':
              'Gentle exercises focused on recovery and heart rate normalization',
          'difficulty': 'Easy',
          'duration': '15 min',
          'focus': 'Recovery',
          'suitableConditions': ['Elevated Heart Rate', 'Fatigue'],
          'exercises': [
            {
              'name': 'Deep Breathing',
              'duration': '3 min',
              'sets': 1,
              'reps': 10,
              'instructions':
                  '4-7-8 breathing technique (4s inhale, 7s hold, 8s exhale)',
            },
            {
              'name': 'Gentle Stretching',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Full body gentle stretches',
            },
            {
              'name': 'Seated Meditation',
              'duration': '5 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Focus on breathing and relaxation',
            },
            {
              'name': 'Progressive Muscle Relaxation',
              'duration': '2 min',
              'sets': 1,
              'reps': 1,
              'instructions': 'Tense and release muscle groups',
            },
          ],
        },
      ];
    } else {
      plans = [
        {
          'id': '4',
          'title': 'Full Body HIIT',
          'description': 'High-intensity interval training for maximum results',
          'difficulty': 'Hard',
          'duration': '30 min',
          'focus': 'Full Body',
          'suitableConditions': ['General'],
          'exercises': [
            {
              'name': 'Jumping Jacks',
              'duration': '1 min',
              'sets': 3,
              'reps': 20,
              'instructions': 'Full range of motion',
            },
            {
              'name': 'Push-ups',
              'duration': '1 min',
              'sets': 3,
              'reps': 15,
              'instructions': 'Keep body straight, lower to 90 degrees',
            },
            {
              'name': 'Squats',
              'duration': '1 min',
              'sets': 3,
              'reps': 20,
              'instructions': 'Keep weight in heels, knees behind toes',
            },
            {
              'name': 'Mountain Climbers',
              'duration': '1 min',
              'sets': 3,
              'reps': 30,
              'instructions': 'Fast pace, keep hips low',
            },
            {
              'name': 'Burpees',
              'duration': '1 min',
              'sets': 3,
              'reps': 10,
              'instructions': 'Full range of motion',
            },
            {
              'name': 'Plank',
              'duration': '1 min',
              'sets': 3,
              'reps': 1,
              'instructions': 'Hold position, keep body straight',
            },
          ],
        },
        {
          'id': '5',
          'title': 'Strength Focus',
          'description': 'Build muscle and increase strength',
          'difficulty': 'Moderate',
          'duration': '45 min',
          'focus': 'Strength',
          'suitableConditions': ['General'],
          'exercises': [
            {
              'name': 'Squats',
              'duration': '5 min',
              'sets': 4,
              'reps': 12,
              'instructions': 'Add weights if available',
            },
            {
              'name': 'Lunges',
              'duration': '5 min',
              'sets': 3,
              'reps': 10,
              'instructions': 'Each leg, keep front knee behind toes',
            },
            {
              'name': 'Push-ups',
              'duration': '5 min',
              'sets': 3,
              'reps': 12,
              'instructions': 'Modify on knees if needed',
            },
            {
              'name': 'Dumbbell Rows',
              'duration': '5 min',
              'sets': 3,
              'reps': 12,
              'instructions': 'Use household items if no weights',
            },
            {
              'name': 'Shoulder Press',
              'duration': '5 min',
              'sets': 3,
              'reps': 12,
              'instructions': 'Use household items if no weights',
            },
            {
              'name': 'Plank',
              'duration': '5 min',
              'sets': 3,
              'reps': 1,
              'instructions': '30-60 second holds',
            },
          ],
        },
      ];
    }

    _workoutPlans = plans;
  }

  void _filterWorkoutPlans() {
    _createMockWorkoutPlans(); // Refresh the base list

    // Apply filters
    _workoutPlans =
        _workoutPlans.where((plan) {
          return (plan['difficulty'] == _selectedDifficulty ||
                  _selectedDifficulty == 'All') &&
              (plan['duration'] == _selectedDuration ||
                  _selectedDuration == 'All') &&
              (plan['focus'] == _selectedFocus || _selectedFocus == 'All');
        }).toList();

    setState(() {});
  }

  void _saveWorkoutToFirebase(Map<String, dynamic> workout) {
    // In a real app, you would save this to Firebase
    // For demo, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout plan added to your schedule')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Workout Planner",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Health status card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              _userHealthStatus == 'Hypertension'
                                  ? [Colors.red.shade900, Colors.red.shade700]
                                  : _userHealthStatus == 'Elevated Heart Rate'
                                  ? [
                                    Colors.orange.shade900,
                                    Colors.orange.shade700,
                                  ]
                                  : [
                                    Colors.green.shade900,
                                    Colors.green.shade700,
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _userHealthStatus == 'Hypertension'
                                    ? Icons.favorite_border
                                    : _userHealthStatus == 'Elevated Heart Rate'
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Health Status: $_userHealthStatus",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _userHealthStatus == 'Hypertension'
                                ? "Your workout plan has been customized for hypertension management."
                                : _userHealthStatus == 'Elevated Heart Rate'
                                ? "Your workout plan is focused on recovery and normalizing your heart rate."
                                : "Your health metrics are normal. Here are some recommended workouts.",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Filter options
                    Text(
                      "Filter Workouts",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Filter cards
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Difficulty selector
                          Row(
                            children: [
                              Text(
                                "Difficulty:",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    _filterChip('Easy', _selectedDifficulty),
                                    _filterChip(
                                      'Moderate',
                                      _selectedDifficulty,
                                    ),
                                    _filterChip('Hard', _selectedDifficulty),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Duration selector
                          Row(
                            children: [
                              Text(
                                "Duration:",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    _filterChip('15 min', _selectedDuration),
                                    _filterChip('30 min', _selectedDuration),
                                    _filterChip('45 min', _selectedDuration),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Focus area selector
                          Row(
                            children: [
                              Text(
                                "Focus:",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    _filterChip('Full Body', _selectedFocus),
                                    _filterChip('Cardio', _selectedFocus),
                                    _filterChip('Strength', _selectedFocus),
                                    _filterChip('Recovery', _selectedFocus),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Apply filter button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _filterWorkoutPlans,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Apply Filters",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Workout plans
                    Text(
                      "Recommended Workout Plans",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    _workoutPlans.isEmpty
                        ? Center(
                          child: Text(
                            "No workout plans match your filters.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        )
                        : Column(
                          children:
                              _workoutPlans
                                  .map((workout) => _buildWorkoutCard(workout))
                                  .toList(),
                        ),
                  ],
                ),
              ),
    );
  }

  Widget _filterChip(String label, String selectedValue) {
    final isSelected = label == selectedValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'Difficulty') {
            _selectedDifficulty = isSelected ? 'All' : label;
          } else if (label == 'Duration') {
            _selectedDuration = isSelected ? 'All' : label;
          } else {
            _selectedFocus = isSelected ? 'All' : label;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        workout['difficulty'] == 'Easy'
                            ? Colors.green
                            : workout['difficulty'] == 'Moderate'
                            ? Colors.orange
                            : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    workout['difficulty'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              workout['description'],
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildWorkoutDetail(Icons.timer, '${workout['duration']}'),
                SizedBox(width: 16),
                _buildWorkoutDetail(
                  Icons.fitness_center,
                  '${workout['focus']}',
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Exercises:",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            ...List.generate(
              workout['exercises'].length > 3 ? 3 : workout['exercises'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout['exercises'][index]['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${workout['exercises'][index]['sets']} sets × ${workout['exercises'][index]['reps']} reps',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (workout['exercises'].length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Text(
                  "... and ${workout['exercises'].length - 3} more exercises",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WorkoutDetailScreen(workout: workout),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveWorkoutToFirebase(workout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Add to My Plan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 18),
        SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}

// Detail screen for a workout
class WorkoutDetailScreen extends StatelessWidget {
  final Map<String, dynamic> workout;

  const WorkoutDetailScreen({Key? key, required this.workout})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          workout['title'],
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade800, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    workout['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailChip(Icons.timer, workout['duration']),
                      _buildDetailChip(Icons.fitness_center, workout['focus']),
                      _buildDetailChip(
                        Icons.speed,
                        workout['difficulty'],
                        color:
                            workout['difficulty'] == 'Easy'
                                ? Colors.green
                                : workout['difficulty'] == 'Moderate'
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Suitable for
            if (workout['suitableConditions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suitable for:",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (String condition in workout['suitableConditions'])
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            condition,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),

            // Exercises
            Text(
              "Exercise Plan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Exercise list
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: workout['exercises'].length,
              itemBuilder: (context, index) {
                final exercise = workout['exercises'][index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise['name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildExerciseSpec(
                                        Icons.timer,
                                        '${exercise['duration']}',
                                      ),
                                      SizedBox(width: 16),
                                      _buildExerciseSpec(
                                        Icons.repeat,
                                        '${exercise['sets']} sets × ${exercise['reps']} reps',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Instructions:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    exercise['instructions'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
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
              },
            ),

            SizedBox(height: 24),

            // Start workout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // In a real app, this would navigate to a workout session
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Starting workout session...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Start Workout",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Add to plan button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // In a real app, this would save to Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Workout plan added to your schedule'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Add to My Plan",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSpec(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
      ],
    );
  }
}
