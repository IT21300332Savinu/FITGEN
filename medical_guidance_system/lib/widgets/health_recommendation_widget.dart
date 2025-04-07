// lib/widgets/health_recommendation_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mock_wearable_provider.dart';

class HealthRecommendationWidget extends StatelessWidget {
  const HealthRecommendationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mockWearableProvider = Provider.of<MockWearableProvider>(context);

    // Analyze health data for recommendations
    String recommendationTitle = "Workout Recommendation";
    String recommendationContent = "Based on your current health status:";
    String recommendationDetail = "";

    // Check heart rate
    final heartRate = mockWearableProvider.heartRate;
    if (heartRate > 100) {
      recommendationDetail +=
          "\n• Your heart rate is elevated. Consider lower intensity exercises today.";
    } else if (heartRate < 60) {
      recommendationDetail +=
          "\n• Your heart rate is low. Start with a proper warm-up before increasing intensity.";
    } else {
      recommendationDetail +=
          "\n• Your heart rate is in a normal range. Good for moderate to high intensity workout.";
    }

    // Check blood pressure
    final bp = mockWearableProvider.bloodPressure;
    final parts = bp.split('/');
    if (parts.length == 2) {
      final systolic = int.tryParse(parts[0]) ?? 0;
      final diastolic = int.tryParse(parts[1]) ?? 0;

      if (systolic > 140 || diastolic > 90) {
        recommendationDetail +=
            "\n• Your blood pressure is elevated. Avoid high-intensity activities and exercises that involve holding your breath.";
        recommendationDetail +=
            "\n• Focus on steady, rhythmic cardio and avoid heavy weightlifting.";
      } else if (systolic < 100 || diastolic < 60) {
        recommendationDetail +=
            "\n• Your blood pressure is below normal range. Increase intensity gradually and stay hydrated.";
      } else {
        recommendationDetail +=
            "\n• Your blood pressure is in a healthy range. Suitable for most exercise types.";
      }
    }

    // Check recent sleep
    final sleep = mockWearableProvider.sleepHours;
    if (sleep < 6) {
      recommendationDetail +=
          "\n• You're not getting enough sleep. Consider a lower intensity workout today and focus on recovery.";
    } else {
      recommendationDetail +=
          "\n• Your sleep levels indicate you're well-rested for exercise.";
    }

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text(
                  recommendationTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              recommendationContent,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 8),
            Text(
              recommendationDetail,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed recommendations
                Navigator.pushNamed(context, '/exercise_guide');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "View Detailed Workout Plan",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
