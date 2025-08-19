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
        },
      ];
    }

    // Base recommendations on personal goal
    switch (userProfile!.personalGoal) {
      case 'Weight Loss':
        recommendations.addAll([
          {
            'title': 'Cardio Focus',
            'description': 'High-intensity cardio for fat burning',
            'exercises': [
              'Brisk walking/jogging 20-30 minutes',
              'Cycling 25 minutes',
              'Swimming 20 minutes',
              'High-intensity interval training (HIIT)',
            ],
            'duration': '45-60 minutes',
            'frequency': '5-6 times per week',
          },
          {
            'title': 'Strength Training',
            'description': 'Build lean muscle to boost metabolism',
            'exercises': [
              'Bodyweight squats 3 sets of 12-15',
              'Push-ups 3 sets of 8-12',
              'Lunges 3 sets of 10 per leg',
              'Plank hold 30-60 seconds',
            ],
            'duration': '30-40 minutes',
            'frequency': '2-3 times per week',
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
              'Deadlifts 4 sets of 5-6 reps',
              'Bench press 4 sets of 6-8 reps',
              'Pull-ups/Rows 4 sets of 6-10 reps',
            ],
            'duration': '60-75 minutes',
            'frequency': '4-5 times per week',
          },
          {
            'title': 'Accessory Work',
            'description': 'Target specific muscle groups',
            'exercises': [
              'Bicep curls 3 sets of 10-12',
              'Tricep dips 3 sets of 8-12',
              'Shoulder press 3 sets of 10-12',
              'Calf raises 3 sets of 15-20',
            ],
            'duration': '30-45 minutes',
            'frequency': '2-3 times per week',
          },
        ]);
        break;

      case 'Maintain Healthy Life':
        recommendations.addAll([
          {
            'title': 'Balanced Fitness',
            'description': 'Mix of cardio, strength, and flexibility',
            'exercises': [
              'Moderate cardio 20-30 minutes',
              'Full-body strength training',
              'Yoga or stretching 15 minutes',
              'Core strengthening exercises',
            ],
            'duration': '45-60 minutes',
            'frequency': '4-5 times per week',
          },
        ]);
        break;
    }

    // Add medical condition modifications
    if (userProfile!.diabetes) {
      recommendations.add({
        'title': 'Diabetes-Friendly Exercise',
        'description': 'Monitor blood sugar before and after exercise',
        'exercises': [
          'Low-impact cardio (walking, swimming)',
          'Resistance training with light weights',
          'Flexibility exercises',
        ],
        'duration': '30-45 minutes',
        'frequency': 'Most days of the week',
        'special_notes': [
          'Check blood sugar before exercising',
          'Carry glucose tablets or snacks',
          'Stay hydrated',
          'Start slowly and gradually increase intensity',
        ],
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
          'Light weight training',
        ],
        'duration': '30-45 minutes',
        'frequency': '5-7 days per week',
        'special_notes': [
          'Avoid heavy lifting or straining',
          'Monitor blood pressure regularly',
          'Warm up and cool down properly',
          'Stop if you feel dizzy or short of breath',
        ],
      });
    }

    if (userProfile!.ckd) {
      recommendations.add({
        'title': 'Kidney-Friendly Exercise',
        'description': 'Low to moderate intensity activities',
        'exercises': [
          'Walking',
          'Light swimming',
          'Chair exercises',
          'Gentle stretching',
        ],
        'duration': '20-30 minutes',
        'frequency': '3-5 times per week',
        'special_notes': [
          'Avoid high-intensity workouts',
          'Stay well hydrated',
          'Monitor for excessive fatigue',
          'Consult your doctor before starting',
        ],
      });
    }

    if (userProfile!.liverDisease) {
      recommendations.add({
        'title': 'Liver Health Support',
        'description': 'Gentle exercise to support liver function',
        'exercises': [
          'Walking',
          'Light yoga',
          'Swimming (if no ascites)',
          'Breathing exercises',
        ],
        'duration': '20-40 minutes',
        'frequency': '4-6 times per week',
        'special_notes': [
          'Avoid overexertion',
          'Listen to your body',
          'Stay hydrated but not overhydrated',
          'Regular medical monitoring',
        ],
      });
    }

    return recommendations;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> recommendations = _generateRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Recommendations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProfile != null) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personalized for You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Age: ${userProfile!.age}'),
                      Text('Goal: ${userProfile!.personalGoal}'),
                      if (userProfile!.diabetes ||
                          userProfile!.hypertension ||
                          userProfile!.ckd ||
                          userProfile!.liverDisease)
                        const Text(
                          'Special considerations included for your medical conditions',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Recommended Workouts',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...recommendations.map(
              (recommendation) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Exercises:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      ...List<String>.from(recommendation['exercises']).map(
                        (exercise) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(exercise)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Duration:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(recommendation['duration']),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Frequency:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(recommendation['frequency']),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (recommendation['special_notes'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            border: Border.all(color: Colors.amber[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Important Notes:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...List<String>.from(
                                recommendation['special_notes'],
                              ).map(
                                (note) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• '),
                                      Expanded(child: Text(note)),
                                    ],
                                  ),
                                ),
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

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Medical Disclaimer:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'These recommendations are AI-generated suggestions based on your profile. '
                    'Always consult with your healthcare provider before starting any new exercise program, '
                    'especially if you have medical conditions. Stop exercising immediately if you '
                    'experience chest pain, dizziness, or shortness of breath.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
