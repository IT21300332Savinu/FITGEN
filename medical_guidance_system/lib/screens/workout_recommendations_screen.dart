import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class WorkoutRecommendationsScreen extends StatelessWidget {
  final UserProfile? userProfile;
  final Map<String, dynamic>? latestReportData;

  const WorkoutRecommendationsScreen({
    super.key,
    this.userProfile,
    this.latestReportData,
  });

  List<Map<String, dynamic>> _generateRecommendations() {
    List<Map<String, dynamic>> recommendations = [];

    if (userProfile == null) {
      return [
        {
          'title': 'General Fitness',
          'description': 'Basic workout routine for overall health',
          'exercises': [
            'Walking 30 minutes',
            'Basic stretching',
            'Light strength training',
          ],
          'duration': '30-45 minutes',
          'frequency': '3-4 times per week',
          'intensity': 'Low to Moderate',
        },
      ];
    }

    // Base recommendations on personal goal and BMI
    double bmi = userProfile!.bmi;
    String bmiCategory = userProfile!.bmiCategory;

    switch (userProfile!.personalGoal) {
      case 'Weight Loss':
        recommendations.addAll([
          {
            'title': 'Cardio Focus for Weight Loss',
            'description':
                'High-intensity cardio optimized for your BMI ($bmiCategory)',
            'exercises': [
              bmi > 30
                  ? 'Low-impact walking 25-30 minutes'
                  : 'Brisk walking/jogging 20-30 minutes',
              bmi > 30 ? 'Stationary cycling 20 minutes' : 'Cycling 25 minutes',
              'Swimming 20 minutes (joint-friendly)',
              bmi <= 25
                  ? 'High-intensity interval training (HIIT)'
                  : 'Moderate interval training',
            ],
            'duration': bmi > 30 ? '35-45 minutes' : '45-60 minutes',
            'frequency': '5-6 times per week',
            'intensity': bmi > 30 ? 'Low to Moderate' : 'Moderate to High',
            'caloriesBurn': '300-500 per session',
          },
          {
            'title': 'Strength Training for Metabolism',
            'description': 'Build lean muscle to boost metabolism',
            'exercises': [
              'Bodyweight squats 3 sets of 12-15',
              bmi > 30
                  ? 'Wall push-ups 3 sets of 8-12'
                  : 'Push-ups 3 sets of 8-12',
              'Lunges 3 sets of 10 per leg',
              'Plank hold 30-60 seconds',
              'Resistance band exercises',
            ],
            'duration': '30-40 minutes',
            'frequency': '3 times per week',
            'intensity': 'Moderate',
            'caloriesBurn': '200-350 per session',
          },
        ]);
        break;

      case 'Muscle Gain':
        recommendations.addAll([
          {
            'title': 'Progressive Strength Training',
            'description':
                'Focus on compound movements with progressive overload',
            'exercises': [
              'Squats 4 sets of 6-8 reps',
              'Deadlifts 4 sets of 5-6 reps (or alternatives if back issues)',
              'Bench press 4 sets of 6-8 reps',
              'Pull-ups/Rows 4 sets of 6-10 reps',
              'Overhead press 3 sets of 8-10 reps',
            ],
            'duration': '60-75 minutes',
            'frequency': '4-5 times per week',
            'intensity': 'High',
            'restPeriods': '2-3 minutes between sets',
          },
          {
            'title': 'Accessory Work',
            'description':
                'Target specific muscle groups for balanced development',
            'exercises': [
              'Bicep curls 3 sets of 10-12',
              'Tricep dips 3 sets of 8-12',
              'Lateral raises 3 sets of 12-15',
              'Calf raises 3 sets of 15-20',
              'Core strengthening exercises',
            ],
            'duration': '30-45 minutes',
            'frequency': '2-3 times per week',
            'intensity': 'Moderate',
          },
        ]);
        break;

      case 'Maintain Healthy Life':
        recommendations.addAll([
          {
            'title': 'Balanced Fitness Routine',
            'description':
                'Mix of cardio, strength, and flexibility for overall wellness',
            'exercises': [
              'Moderate cardio 20-30 minutes',
              'Full-body strength training',
              'Yoga or stretching 15 minutes',
              'Core strengthening exercises',
              'Balance and coordination drills',
            ],
            'duration': '45-60 minutes',
            'frequency': '4-5 times per week',
            'intensity': 'Low to Moderate',
          },
        ]);
        break;
    }

    // Add medical condition specific modifications
    _addMedicalConditionModifications(recommendations);

    return recommendations;
  }

  void _addMedicalConditionModifications(
    List<Map<String, dynamic>> recommendations,
  ) {
    if (userProfile!.diabetes) {
      recommendations.add({
        'title': 'Diabetes-Friendly Exercise',
        'description': 'Specialized routine for blood sugar management',
        'exercises': [
          'Low-impact cardio (walking, swimming)',
          'Resistance training with light to moderate weights',
          'Flexibility exercises',
          'Balance training to prevent falls',
        ],
        'duration': '30-45 minutes',
        'frequency': 'Most days of the week',
        'intensity': 'Low to Moderate',
        'special_notes': [
          '🩸 Check blood sugar before and after exercising',
          '🍬 Carry glucose tablets or snacks',
          '💧 Stay well hydrated',
          '📈 Start slowly and gradually increase intensity',
          '⏰ Best times: 1-3 hours after meals',
        ],
        'bloodSugarTargets': {
          'pre_exercise': '100-180 mg/dL',
          'post_exercise': 'Monitor for 2-4 hours',
        },
      });
    }

    if (userProfile!.hypertension) {
      recommendations.add({
        'title': 'Blood Pressure Management',
        'description': 'Focus on moderate-intensity aerobic exercise',
        'exercises': [
          'Brisk walking',
          'Swimming',
          'Cycling',
          'Light weight training (avoid heavy lifting)',
          'Tai Chi or gentle yoga',
        ],
        'duration': '30-45 minutes',
        'frequency': '5-7 days per week',
        'intensity': 'Low to Moderate',
        'special_notes': [
          '⚠️ Avoid heavy lifting or straining (Valsalva maneuver)',
          '📊 Monitor blood pressure regularly',
          '🔄 Include proper warm-up and cool-down',
          '🛑 Stop if you feel dizzy or short of breath',
          '💊 Take medications as prescribed',
        ],
        'bpTargets': 'Keep systolic <140 mmHg during exercise',
      });
    }

    if (userProfile!.ckd) {
      recommendations.add({
        'title': 'Kidney-Friendly Exercise',
        'description':
            'Low to moderate intensity activities to support kidney health',
        'exercises': [
          'Walking at comfortable pace',
          'Light swimming (if no fluid restrictions)',
          'Chair exercises',
          'Gentle stretching',
          'Breathing exercises',
        ],
        'duration': '20-30 minutes',
        'frequency': '3-5 times per week',
        'intensity': 'Low',
        'special_notes': [
          '🚫 Avoid high-intensity workouts',
          '💧 Follow fluid restrictions if prescribed',
          '😴 Monitor for excessive fatigue',
          '👨‍⚕️ Get clearance from nephrologist before starting',
          '📋 Regular kidney function monitoring',
        ],
        'limitations': 'May need to adjust based on kidney function stage',
      });
    }

    if (userProfile!.liverDisease) {
      recommendations.add({
        'title': 'Liver Health Support',
        'description':
            'Gentle exercise to support liver function without overexertion',
        'exercises': [
          'Walking',
          'Light yoga',
          'Swimming (if no ascites)',
          'Breathing exercises',
          'Gentle stretching',
        ],
        'duration': '20-40 minutes',
        'frequency': '4-6 times per week',
        'intensity': 'Low',
        'special_notes': [
          '🎯 Avoid overexertion',
          '👂 Listen to your body',
          '💧 Stay hydrated but not overhydrated',
          '📅 Regular medical monitoring',
          '🍎 Combine with liver-healthy nutrition',
        ],
      });
    }

    if (userProfile!.fattyLiver) {
      recommendations.add({
        'title': 'Fatty Liver Management',
        'description': 'Exercise routine to help reduce liver fat content',
        'exercises': [
          'Moderate aerobic exercise',
          'Resistance training 2x per week',
          'Walking after meals',
          'Swimming',
          'Cycling',
        ],
        'duration': '30-45 minutes',
        'frequency': '5-6 times per week',
        'intensity': 'Moderate',
        'special_notes': [
          '🎯 Aim for gradual weight loss (1-2 lbs/week)',
          '🥗 Combine with healthy diet',
          '📊 Regular liver function tests',
          '💪 Resistance training helps reduce liver fat',
        ],
        'benefits': 'Can reduce liver fat by 20-30% in 3-6 months',
      });
    }
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'moderate':
      case 'low to moderate':
        return Colors.orange;
      case 'high':
      case 'moderate to high':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getWorkoutIcon(String title) {
    if (title.toLowerCase().contains('cardio')) return Icons.directions_run;
    if (title.toLowerCase().contains('strength')) return Icons.fitness_center;
    if (title.toLowerCase().contains('diabetes')) return Icons.bloodtype;
    if (title.toLowerCase().contains('blood pressure')) return Icons.favorite;
    if (title.toLowerCase().contains('kidney')) return Icons.water_drop;
    if (title.toLowerCase().contains('liver')) return Icons.medical_services;
    return Icons.sports_gymnastics;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> recommendations = _generateRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Recommendations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personalized Header
            if (userProfile != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.orange[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personalized Workout Plan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Tailored for your ${userProfile!.personalGoal.toLowerCase()} goal',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildProfileChip(
                          'Age: ${userProfile!.age}',
                          Icons.cake,
                        ),
                        const SizedBox(width: 12),
                        _buildProfileChip(
                          'BMI: ${userProfile!.bmi.toStringAsFixed(1)}',
                          Icons.monitor_weight,
                        ),
                        const SizedBox(width: 12),
                        _buildProfileChip(
                          '${userProfile!.selectedConditionsCount} conditions',
                          Icons.medical_services,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Recommended Workouts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your health profile and medical conditions',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Workout Recommendations
            ...recommendations.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> recommendation = entry.value;
              bool isSpecialCondition = recommendation['special_notes'] != null;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Card(
                  elevation: isSpecialCondition ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isSpecialCondition
                        ? BorderSide(color: Colors.amber[300]!, width: 2)
                        : BorderSide.none,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isSpecialCondition
                          ? LinearGradient(
                              colors: [Colors.amber[50]!, Colors.orange[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getIntensityColor(
                                    recommendation['intensity'] ?? 'moderate',
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getWorkoutIcon(recommendation['title']),
                                  color: _getIntensityColor(
                                    recommendation['intensity'] ?? 'moderate',
                                  ),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recommendation['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recommendation['description'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Exercise List
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.list,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Exercises:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...List<String>.from(
                                  recommendation['exercises'],
                                ).map(
                                  (exercise) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(
                                            top: 8,
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getIntensityColor(
                                              recommendation['intensity'] ??
                                                  'moderate',
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            exercise,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Workout Details
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDetailItem(
                                        Icons.schedule,
                                        'Duration',
                                        recommendation['duration'],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey[300],
                                    ),
                                    Expanded(
                                      child: _buildDetailItem(
                                        Icons.repeat,
                                        'Frequency',
                                        recommendation['frequency'],
                                      ),
                                    ),
                                  ],
                                ),
                                if (recommendation['intensity'] != null) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailItem(
                                          Icons.speed,
                                          'Intensity',
                                          recommendation['intensity'],
                                          color: _getIntensityColor(
                                            recommendation['intensity'],
                                          ),
                                        ),
                                      ),
                                      if (recommendation['caloriesBurn'] !=
                                          null) ...[
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: Colors.grey[300],
                                        ),
                                        Expanded(
                                          child: _buildDetailItem(
                                            Icons.local_fire_department,
                                            'Calories',
                                            recommendation['caloriesBurn'],
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Special Medical Notes
                          if (recommendation['special_notes'] != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Medical Considerations:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...List<String>.from(
                                    recommendation['special_notes'],
                                  ).map(
                                    (note) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        note,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Additional Info (targets, benefits, etc.)
                          if (recommendation['bloodSugarTargets'] != null ||
                              recommendation['bpTargets'] != null ||
                              recommendation['benefits'] != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Additional Information:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (recommendation['bloodSugarTargets'] !=
                                      null)
                                    Text(
                                      'Target Blood Sugar: ${recommendation['bloodSugarTargets']['pre_exercise']}',
                                    ),
                                  if (recommendation['bpTargets'] != null)
                                    Text(
                                      'BP Target: ${recommendation['bpTargets']}',
                                    ),
                                  if (recommendation['benefits'] != null)
                                    Text(
                                      'Expected Benefits: ${recommendation['benefits']}',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),

            // Medical Disclaimer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.red, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Medical Disclaimer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'These recommendations are AI-generated suggestions based on your health profile. '
                    'Always consult with your healthcare provider before starting any new exercise program, '
                    'especially if you have medical conditions. Stop exercising immediately if you '
                    'experience chest pain, dizziness, shortness of breath, or unusual fatigue.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For diabetes: Monitor blood sugar levels closely. For hypertension: Avoid heavy lifting. '
                    'For kidney/liver conditions: Follow your doctor\'s activity restrictions.',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
