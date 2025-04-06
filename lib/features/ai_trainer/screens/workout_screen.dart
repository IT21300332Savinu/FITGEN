// file: lib/screens/workout_screen.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../services/firebase_service.dart';
import '../services/pose_analyzer_service.dart';
import '../models/workout_session.dart';
import '../widgets/pose_visualization.dart';

// Improved WorkoutScreen class
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

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  // Platform check
  final bool isWeb = false;
  
  // Camera controller
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFrontFacing = true;

  // Pose detector
  late PoseAnalyzerService _poseAnalyzer;
  bool _poseAnalyzerInitialized = false;

  // Workout state
  int _repCount = 0;
  double _formQuality = 0.75;
  List<String> _formIssues = ['Getting ready...'];
  List<PoseLandmark>? _landmarks;
  DateTime _startTime = DateTime.now();
  bool _isWorkoutActive = false;
  
  // Timer for workout duration
  int _durationSeconds = 0;
  Timer? _durationTimer;
  
  // Simulation timer for web demo
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize pose analyzer
    _initializePoseAnalyzer();
    
    // Start workout duration timer
    _startDurationTimer();
    
    // Initialize camera with a slight delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      _initializeCamera();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle to properly manage camera
    if (state == AppLifecycleState.inactive) {
      _cameraController?.stopImageStream();
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _initializeCamera();
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWorkoutActive && mounted) {
        setState(() {
          _durationSeconds++;
        });
      }
    });
  }

  Future<void> _initializePoseAnalyzer() async {
    try {
      _poseAnalyzer = PoseAnalyzerService();
      await _poseAnalyzer.initialize(widget.exerciseName);
      setState(() {
        _poseAnalyzerInitialized = true;
      });
      
      if (isWeb) {
        _setupWebSimulation();
      }
    } catch (e) {
      print('Error initializing pose analyzer: $e');
    }
  }

   Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print('No cameras available');
        setState(() {
          _isCameraInitialized = true; // Set to true so UI shows demo mode
        });
        return;
      }
      
      // Use front camera if available
      final frontCameras = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.front
      ).toList();
      
      final camera = frontCameras.isNotEmpty ? frontCameras.first : cameras.first;
      _isFrontFacing = camera.lensDirection == CameraLensDirection.front;
      
      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      if (!mounted) return;
      
      // Start image stream for pose detection
      await _cameraController!.startImageStream(_processImage);
      
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      // Show a more detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        )
      );
      
      setState(() {
        _isCameraInitialized = true; // Still set to true to show fallback UI
      });
    }
  }
  
  // Process camera image for pose detection
  void _processImage(CameraImage image) async {
    if (!_isWorkoutActive || !_poseAnalyzerInitialized) return;
    
    try {
      final result = await _poseAnalyzer.processFrame(
        image, 
        _cameraController!.description
      );
      
      if (result != null && mounted) {
        setState(() {
          _repCount = result.repCount;
          _formQuality = result.formQuality;
          _formIssues = result.formIssues;
          _landmarks = result.landmarks;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    }
  }
  
  void _setupWebSimulation() {
    // For web demo, create simulated data
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isWorkoutActive || !mounted) return;
      
      // Create simulated movements based on exercise type
      final isSquat = widget.exerciseName.toLowerCase() == 'squat';
      
      // Cycle through different exercise positions
      final cyclePosition = (_durationSeconds % 4) / 4; // 0 to 1 over 4 seconds
      
      // Simulate realistic movement pattern (down then up)
      final position = cyclePosition < 0.5 
          ? cyclePosition * 2 // 0 to 1 (going down)
          : (1 - (cyclePosition - 0.5) * 2); // 1 to 0 (going up)
      
      // Add a repetition at the top of the movement
      if (cyclePosition > 0.9 && cyclePosition < 0.95) {
        setState(() {
          _repCount = (_durationSeconds / 4).floor();
        });
      }
      
      // Adjust form quality every few seconds
      if (_durationSeconds % 10 == 0) {
        setState(() {
          _formQuality = 0.7 + (math.Random().nextDouble() * 0.3);
        });
      }
      
      // Add occasional form issues
      if (_durationSeconds % 15 == 0) {
        setState(() {
          if (isSquat) {
            _formIssues = ['Keep your knees aligned with your toes'];
          } else {
            _formIssues = ['Keep your core engaged throughout the movement'];
          }
        });
      } else if (_durationSeconds % 12 == 0) {
        setState(() {
          if (isSquat) {
            _formIssues = ['Lower your hips more for full depth'];
          } else {
            _formIssues = ['Lower your chest closer to the ground'];
          }
        });
      } else if (_durationSeconds % 7 == 0) {
        setState(() {
          _formIssues = ['Good form! Keep it up.'];
        });
      }
    });
  }

  Future<void> _endWorkout() async {
    if (!_isWorkoutActive) return;

    setState(() {
      _isWorkoutActive = false;
    });
    
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
    
    // Dispose timers
    _durationTimer?.cancel();
    _simulationTimer?.cancel();

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context, 
        listen: false
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
        averageHeartRate: 125, // Placeholder - would come from wearable
        averageFormScore: _formQuality * 100,
      );

      // Save to Firebase
      await firebaseService.saveWorkoutSession(session);

      // Navigate back with completion data
      Navigator.pop(context, {
        'completed': true, 
        'repCount': _repCount, 
        'duration': _durationSeconds,
        'formScore': _formQuality * 100
      });
    } catch (e) {
      print('Error saving workout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving workout: ${e.toString().substring(0, math.min(e.toString().length, 100))}')
        )
      );
      Navigator.pop(context, {'completed': false});
    }
  }

  int _calculateCaloriesBurned() {
    // Simple estimation based on exercise type and duration
    double mets = widget.workoutType.toLowerCase() == 'cardio' ? 6.0 : 4.5;
    int weightKg = 70; // Default weight - would come from user profile
    double durationHours = _durationSeconds / 3600;

    return (mets * weightKg * durationHours * 3.5).round();
  }
  
  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _simulationTimer?.cancel();
    _disposeCamera();
    _poseAnalyzer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isCameraInitialized
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
          // Camera preview with pose overlay
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview or demo placeholder
                if (isWeb || _cameraController == null)
                  _buildPlaceholderPreview()
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CameraPreview(_cameraController!),
                  ),
                
                // Pose visualization overlay
                if (_landmarks != null && _landmarks!.isNotEmpty)
                  PoseVisualization(
                    landmarks: _landmarks,
                    screenSize: MediaQuery.of(context).size,
                    cameraSize: isWeb || _cameraController == null
                        ? Size(MediaQuery.of(context).size.width, 
                               MediaQuery.of(context).size.width * 0.75)
                        : Size(
                            _cameraController!.value.previewSize!.height,
                            _cameraController!.value.previewSize!.width,
                          ),
                    isFrontFacing: _isFrontFacing,
                  ),
                
                // Rep counter overlay
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Reps: $_repCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Duration timer overlay
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_durationSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats and feedback panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exercise name and type
                  Text(
                    '${widget.exerciseName} (${widget.workoutType})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox(
                        icon: Icons.fitness_center,
                        value: '$_repCount',
                        label: 'Repetitions',
                        color: Theme.of(context).primaryColor,
                      ),
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

                  // Form quality indicator
                  Row(
                    children: [
                      const Text(
                        'Form Quality:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormQualityIndicator(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form feedback
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _formIssues.isNotEmpty && _formIssues.first != 'Good form! Keep it up.'
                            ? Colors.amber.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _formIssues.isNotEmpty && _formIssues.first != 'Good form! Keep it up.'
                              ? Colors.amber
                              : Colors.green,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formIssues.isNotEmpty && _formIssues.first != 'Good form! Keep it up.'
                                ? 'Form Feedback:'
                                : 'Great Job!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _formIssues.isNotEmpty && _formIssues.first != 'Good form! Keep it up.'
                                  ? Colors.amber.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formIssues.isNotEmpty
                                ? _formIssues.first
                                : 'Excellent form! Keep up the great work!',
                            style: TextStyle(
                              color: _formIssues.isNotEmpty && _formIssues.first != 'Good form! Keep it up.'
                                  ? Colors.amber.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
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

 Widget _buildPlaceholderPreview() {
  return Container(
    color: Colors.grey[900],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.exerciseName.toLowerCase() == 'squat'
                ? Icons.accessibility_new // Use this for squat exercise
                : Icons.fitness_center,    // Use this for other exercises
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'Pose analysis active',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            isWeb
                ? 'Web demo mode (camera not available)'
                : 'Camera initializing...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
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
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
    } else if (_formQuality >= 0.6) {
      color = Colors.amber;
    } else {
      color = Colors.red;
    }

    return Container(
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