import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../services/pose_analyzer_service.dart';
import '../models/workout_session.dart';

class WorkoutScreen extends StatefulWidget {
  final String exerciseName;
  final String workoutType;

  const WorkoutScreen({
    Key? key,
    required this.exerciseName,
    required this.workoutType,
  }) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Camera controller
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;

  // Pose analyzer
  late PoseAnalyzerService _poseAnalyzer;

  // Workout state
  final int _repCount = 0;
  final double _formQuality = 0.0;
  final List<String> _formIssues = [];
  DateTime _startTime = DateTime.now();
  bool _isWorkoutActive = false;

  // Timer for workout duration
  final int _durationSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Initialize pose analyzer
    _poseAnalyzer = PoseAnalyzerService();
    _initializePoseAnalyzer();

    // Initialize camera
    _initializeCamera();

    // Start workout timer
    _startWorkout();
  }

  Future<void> _initializePoseAnalyzer() async {
    await _poseAnalyzer.initialize(widget.exerciseName);
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (!mounted) return;

        setState(() {
          _isCameraInitialized = true;
        });

        // Start image stream for pose analysis
        // _startImageStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _startTime = DateTime.now();
    });

    // Start timer
    // In a real app, you would use a Timer to update _durationSeconds
  }

  Future<void> _endWorkout() async {
    if (!_isWorkoutActive) return;

    setState(() {
      _isWorkoutActive = false;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      // Create workout session
      final session = WorkoutSession(
        workoutType: widget.workoutType,
        timestamp: _startTime,
        durationMinutes: (_durationSeconds / 60).ceil(),
        exercises: [
          ExerciseSet(
            exerciseName: widget.exerciseName,
            sets: 1,
            reps: _repCount,
            formScore: _formQuality * 100,
            formIssues: _formIssues,
          ),
        ],
        caloriesBurned: _calculateCaloriesBurned(),
        averageHeartRate: 120, // Placeholder - would come from wearable
        averageFormScore: _formQuality * 100,
      );

      // Save to Firebase
      await firebaseService.saveWorkoutSession(session);

      // Navigate back to home screen
      Navigator.pop(context, {'completed': true, 'repCount': _repCount});
    } catch (e) {
      print('Error saving workout: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving workout: $e')));
    }
  }

  int _calculateCaloriesBurned() {
    // Simple estimation based on exercise type and duration
    double mets = 4.0; // Metabolic equivalent for moderate exercise
    int weightKg = 70; // Default weight - would come from user profile
    int durationHours = (_durationSeconds / 3600).toInt();

    return (mets * weightKg * durationHours * 3.5).round();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.black,
      ),
      body:
          _isCameraInitialized
              ? _buildWorkoutBody()
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endWorkout,
        icon: const Icon(Icons.stop),
        label: const Text('End Workout'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildWorkoutBody() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Camera preview
          Expanded(
            flex: 3,
            child: Center(child: CameraPreview(_cameraController!)),
          ),

          // Stats panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Rep counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Repetitions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_repCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Form quality
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Form Quality',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildFormQualityIndicator(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Form feedback
                  _formIssues.isNotEmpty
                      ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Form Tips:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_formIssues.first),
                          ],
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          'Great form! Keep it up!',
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormQualityIndicator() {
    Color color;
    if (_formQuality >= 0.8) {
      color = Colors.green;
    } else if (_formQuality >= 0.5) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      width: 150,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: _formQuality,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Center(
            child: Text(
              '${(_formQuality * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _formQuality > 0.5 ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
