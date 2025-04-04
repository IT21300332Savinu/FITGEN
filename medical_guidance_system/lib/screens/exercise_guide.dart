// lib/screens/exercise_guide.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mock_wearable_provider.dart';

class ExerciseGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockWearableProvider = Provider.of<MockWearableProvider>(context);

    // Determine exercise recommendations based on health data
    List<Map<String, dynamic>> exercises = [];
    String condition = "normal";

    // Check blood pressure
    final bp = mockWearableProvider.bloodPressure;
    final parts = bp.split('/');
    if (parts.length == 2) {
      final systolic = int.tryParse(parts[0]) ?? 0;

      if (systolic > 140) {
        condition = "hypertension";
      }
    }

    // Check heart rate
    final heartRate = mockWearableProvider.heartRate;
    if (heartRate > 100) {
      condition = "elevated_heart_rate";
    }

    // Generate exercise recommendations based on condition
    switch (condition) {
      case "hypertension":
        exercises = [
          {
            'name': 'Walking',
            'description': 'Moderate-paced walking on flat ground',
            'duration': '20-30 minutes',
            'intensity': 'Low to moderate',
            'benefits':
                'Helps lower blood pressure, improves cardiovascular health without strain',
            'warning': 'Stop if you feel dizzy or short of breath',
          },
          {
            'name': 'Water Aerobics',
            'description': 'Light movements in water with buoyancy support',
            'duration': '20-30 minutes',
            'intensity': 'Low',
            'benefits':
                'Reduces stress on joints, provides resistance while keeping heart rate lower',
            'warning': 'Maintain proper hydration even when in water',
          },
          {
            'name': 'Yoga (Gentle)',
            'description': 'Slow, controlled movements with deep breathing',
            'duration': '15-20 minutes',
            'intensity': 'Very low',
            'benefits':
                'Reduces stress, improves flexibility, can help lower blood pressure',
            'warning': 'Avoid positions with head below heart',
          },
        ];
        break;
      case "elevated_heart_rate":
        exercises = [
          {
            'name': 'Deep Breathing',
            'description': 'Slow, controlled breathing exercises',
            'duration': '5-10 minutes',
            'intensity': 'Very low',
            'benefits': 'Helps reduce heart rate and stress levels',
            'warning': 'Sit in a comfortable position while performing',
          },
          {
            'name': 'Gentle Stretching',
            'description': 'Light full-body stretches',
            'duration': '10-15 minutes',
            'intensity': 'Low',
            'benefits': 'Improves circulation without elevating heart rate',
            'warning': 'No bouncing or forced stretches',
          },
          {
            'name': 'Walking',
            'description': 'Very slow-paced walking',
            'duration': '10-15 minutes',
            'intensity': 'Low',
            'benefits':
                'Maintains mobility while allowing heart rate to normalize',
            'warning': 'Stop immediately if heart rate increases significantly',
          },
        ];
        break;
      default:
        exercises = [
          {
            'name': 'Brisk Walking',
            'description': 'Fast-paced walking with arm movement',
            'duration': '30-45 minutes',
            'intensity': 'Moderate',
            'benefits': 'Cardiovascular health, calorie burning, improved mood',
            'warning': 'Stay hydrated throughout',
          },
          {
            'name': 'Strength Training',
            'description': 'Resistance exercises targeting major muscle groups',
            'duration': '30-40 minutes',
            'intensity': 'Moderate to high',
            'benefits':
                'Muscle building, metabolic boost, bone density improvement',
            'warning': 'Use proper form to avoid injuries',
          },
          {
            'name': 'HIIT Workout',
            'description': 'High-intensity intervals with rest periods',
            'duration': '20-30 minutes',
            'intensity': 'High',
            'benefits':
                'Efficient calorie burning, improved cardiovascular fitness',
            'warning': 'Not recommended for beginners without supervision',
          },
        ];
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Exercise Guidance",
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
            // Header with condition-specific message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      condition == "hypertension"
                          ? [Colors.red.shade900, Colors.red.shade700]
                          : condition == "elevated_heart_rate"
                          ? [Colors.orange.shade900, Colors.orange.shade700]
                          : [Colors.green.shade900, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition == "hypertension"
                        ? "Hypertension-Friendly Workout Plan"
                        : condition == "elevated_heart_rate"
                        ? "Heart Rate Recovery Workout Plan"
                        : "Optimal Fitness Workout Plan",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    condition == "hypertension"
                        ? "Your blood pressure readings suggest you should focus on exercises that won't increase pressure. Here are some safe options:"
                        : condition == "elevated_heart_rate"
                        ? "Your elevated heart rate suggests you should focus on recovery and low-intensity activities today:"
                        : "Your health metrics are in a good range. Here's a balanced plan to optimize your fitness:",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Recommended exercises
            Text(
              "Recommended Exercises",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Exercise list
            ...exercises
                .map((exercise) => buildExerciseCard(exercise))
                .toList(),

            SizedBox(height: 24),

            // Health monitoring reminder
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monitor_heart,
                          color: Colors.orange,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Health Monitoring Reminder",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "• Monitor your heart rate during exercise\n• Stay hydrated throughout your workout\n• Stop immediately if you feel dizzy or short of breath\n• Allow proper recovery time between workouts",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 8),
            Text(
              exercise['description'],
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: buildExerciseDetail(
                    "Duration",
                    exercise['duration'],
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: buildExerciseDetail(
                    "Intensity",
                    exercise['intensity'],
                    Icons.speed,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            buildExerciseSection(
              "Benefits",
              exercise['benefits'],
              Icons.check_circle,
            ),
            SizedBox(height: 8),
            buildExerciseSection(
              "Warning",
              exercise['warning'],
              Icons.warning_amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExerciseDetail(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 18),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildExerciseSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange, size: 18),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 26.0),
          child: Text(
            content,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
