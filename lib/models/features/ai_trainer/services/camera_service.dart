import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_service.dart';
import '../services/pose_analyzer_service.dart';
import '../models/workout_session.dart';

class WorkoutScreen extends StatefulWidget {
  final String exerciseName;
  final String workoutType;

  const WorkoutScreen({
    super.key,
    required this.exerciseName,
    required this.workoutType,
  });

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Web platform check
  bool get isWeb => kIsWeb;
  
  // Camera controller
  CameraController? _cameraController;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;

  // Pose analyzer
  late PoseAnalyzerService _poseAnalyzer;

  // Workout state
  int _repCount = 0;
  double _formQuality = 0.75; // Initial quality for demo
  List<String> _formIssues = [];
  DateTime _startTime = DateTime.now();
  bool _isWorkoutActive = false;

  // Timer for workout duration
  int _durationSeconds = 0;

  // For simulation in web mode
  int _simulationCounter = 0;

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

    // If on web, set up demo simulation
    if (isWeb) {
      _setupWebSimulation();
    }
  }

  Future<void> _initializePoseAnalyzer() async {
    await _poseAnalyzer.initialize(widget.exerciseName);
  }

  Future<void> _initializeCamera() async {
    try {
      // Conditional path for web
      if (isWeb) {
        // For web, we skip the normal camera initialization process
        // and simply set the flag to true to proceed with the app flow
        setState(() {
          _isCameraInitialized = true;
        });
        // Demo mode for web will use simulated values
      } 
      // Mobile device path
      else {
        // Regular camera initialization flow for mobile devices
        cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras[0],  // Use the first available camera
            ResolutionPreset.medium,  // Set resolution (medium is a good balance)
            enableAudio: false,  // Disable audio for a fitness app
          );
          
          // Initialize the controller
          await _cameraController!.initialize();
          
          // Check if widget is still mounted before updating state
          if (!mounted) return;
          
          setState(() {
            _isCameraInitialized = true;
          });
          
          // Start pose analysis with camera stream
          // This would be implemented for a full version
          // _startPoseAnalysis();
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      // Fallback to demo mode if camera fails
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  void _setupWebSimulation() {
    // Simulate workout progress for demo purposes
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      _simulationCounter++;
      
      // Simulate rep counting
      if (_simulationCounter % 3 == 0) {
        setState(() {
          _repCount++;
          // Randomly vary form quality for demo
          _formQuality = 0.65 + (0.3 * (_repCount % 5) / 5);
          
          // Add form issues occasionally
          if (_repCount % 4 == 0) {
            _formIssues = ['Keep your back straight'];
          } else if (_repCount % 3 == 0) {
            _formIssues = ['Lower your hips more'];
          } else {
            _formIssues = [];
          }
        });
      }
      
      // Update workout duration
      setState(() {
        _durationSeconds += 2;
      });
      
      // Continue simulation
      if (_isWorkoutActive) {
        _setupWebSimulation();
      }
    });
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _startTime = DateTime.now();
    });

    // In a real implementation, we would start a Timer to update _durationSeconds
    // For the demo, this is handled by _setupWebSimulation on web
    if (!isWeb) {
      // Start timer for mobile devices
      // This would be implemented for a full version
    }
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
    double durationHours = _durationSeconds / 3600;

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
          // Camera preview or placeholder
          Expanded(
            flex: 3,
            child: Center(
              child: isWeb 
                // For web, show a placeholder with simulated pose skeleton
                ? Container(
                    color: Colors.grey[800],
                    child: Stack(
                      children: [
                        // Placeholder image or animation could go here
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Simulated pose detection visualization
                              Icon(
                                Icons.accessibility_new,
                                size: 120,
                                color: _formQuality > 0.7 ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Camera preview unavailable in web demo',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Form analysis simulation active',
                                style: TextStyle(
                                  color: _formQuality > 0.7 ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Exercise-specific guide lines could be drawn here
                        // This would help visualize the correct form
                      ],
                    ),
                  )
                // For mobile, show actual camera preview
                : CameraPreview(_cameraController!),
            ),
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
                  // Duration and calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox(
                        icon: Icons.timer,
                        value: _formatDuration(_durationSeconds),
                        label: 'Duration',
                      ),
                      _buildStatBox(
                        icon: Icons.local_fire_department,
                        value: '${_calculateCaloriesBurned()}',
                        label: 'Calories',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
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

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    Color color = Colors.blue,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
  
  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}