import 'package:flutter/material.dart';

class ExerciseInstructionScreen extends StatelessWidget {
  final String exerciseType;
  final VoidCallback onStartWorkout;

  const ExerciseInstructionScreen({
    Key? key,
    required this.exerciseType,
    required this.onStartWorkout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$exerciseType Instructions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise demonstration image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getExerciseIcon(),
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Exercise title
              Text(
                exerciseType,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Instructions
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionSection(
                        'Setup',
                        _getSetupInstructions(),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionSection(
                        'Execution',
                        _getExecutionInstructions(),
                      ),
                      const SizedBox(height: 20),
                      _buildInstructionSection(
                        'Important Tips',
                        _getTips(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Start workout button
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: onStartWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Start Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionSection(String title, List<String> instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6C5CE7),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...instructions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C5CE7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  IconData _getExerciseIcon() {
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
        return Icons.fitness_center;
      case 'push up':
        return Icons.accessibility_new;
      case 'squat':
        return Icons.self_improvement;
      default:
        return Icons.sports_gymnastics;
    }
  }

  List<String> _getSetupInstructions() {
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
        return [
          'Stand with feet shoulder-width apart',
          'Hold dumbbells or weights at your sides',
          'Keep your arms straight and shoulders back',
          'Face the camera so your side profile is visible',
        ];
      default:
        return [
          'Position yourself in front of the camera',
          'Make sure your full body is visible',
          'Ensure good lighting for accurate detection',
        ];
    }
  }

  List<String> _getExecutionInstructions() {
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
        return [
          'Keep your upper arms stationary',
          'Slowly curl the weights up by contracting your biceps',
          'Pause briefly at the top of the movement',
          'Slowly lower the weights back to starting position',
          'Maintain control throughout the entire movement',
        ];
      default:
        return [
          'Follow the AI trainer guidance',
          'Maintain proper form throughout',
          'Listen to voice feedback',
        ];
    }
  }

  List<String> _getTips() {
    switch (exerciseType.toLowerCase()) {
      case 'bicep curl':
        return [
          'Don\'t swing your body or use momentum',
          'Keep your wrists straight and stable',
          'Focus on the muscle contraction',
          'Breathe out as you curl up, breathe in as you lower',
          'Start with lighter weights to perfect your form',
        ];
      default:
        return [
          'Focus on proper form over speed',
          'Listen to the AI trainer feedback',
          'Take breaks if you feel tired',
        ];
    }
  }
}