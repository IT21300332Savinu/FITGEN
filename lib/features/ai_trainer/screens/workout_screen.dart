// lib/features/ai_trainer/screens/workout_screen.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:fitgen/features/painters/form_feedback_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';
import '../models/workout_session.dart';
import '../exercise/exercise_detector.dart';
import '../exercise/unified_exercise_detector.dart';
import '../models/exercise_models.dart';
import '../services/voice_coach_service.dart';
import '../../gamification/services/workout_integration_service.dart';

class WorkoutScreen extends StatefulWidget {
  final String exerciseName;
  final String workoutType;

  const WorkoutScreen({
    Key? key,
    required this.exerciseName,
    required this.workoutType,
  }) : super(key: key);

  @override
  State<WorkoutScreen> createState() => WorkoutScreenState();
}

class WorkoutScreenState extends State<WorkoutScreen>
    with WidgetsBindingObserver {
  // Camera controller
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  bool _isUsingFrontCamera = false;

  // Pose detector and exercise detector
  PoseDetector? _poseDetector;
  UnifiedExerciseDetector? _exerciseDetector;
  VoiceCoachService? _voiceCoach;
  bool _poseDetectorInitialized = false;

  // Workout state
  int _repCount = 0;
  double _formQuality = 0.75;
  List<String> _formIssues = ['Getting ready to detect your pose...'];
  final DateTime _startTime = DateTime.now();
  bool _isWorkoutActive = true;

  // Exercise analysis
  List<Pose> _poses = [];
  ExerciseMetrics? _exerciseMetrics;
  Size? _absoluteImageSize;

  // Timer for workout duration
  int _durationSeconds = 0;
  Timer? _durationTimer;

  // Processing control
  bool _isProcessingFrame = false;
  bool _isDetecting = false;

  // Display settings
  bool _showFormFeedback = true;
  bool _showAllKeypoints = true;
  bool _voiceCoachEnabled = true;

  // Full screen mode
  bool _isFullScreen = true;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Set full screen and hide system UI
    _setFullScreenMode();

    _initializeServices();
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );

    // Hide controls after 3 seconds
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    setState(() {
      _showControls = true;
    });

    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isFullScreen) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
      _resetControlsTimer();
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
      _controlsTimer?.cancel();
      setState(() {
        _showControls = true;
      });
    }
  }

  Future<void> _initializeServices() async {
    // Start workout duration timer
    _startDurationTimer();

    // Initialize exercise detector
    _exerciseDetector = UnifiedExerciseDetector();

    // Map exercise name to exercise type
    ExerciseType exerciseType = _getExerciseTypeFromName(widget.exerciseName);
    debugPrint(
      '🏋️‍♂️ Setting exercise type: $exerciseType for exercise: ${widget.exerciseName}',
    );
    _exerciseDetector!.setExerciseType(exerciseType);

    // Initialize voice coach
    _voiceCoach = VoiceCoachService();
    _voiceCoach!.setExerciseType(exerciseType);
    if (_voiceCoachEnabled) {
      await _voiceCoach!.initialize();
    }

    // Initialize pose detector
    await _initializePoseDetector();

    // Then initialize camera
    await _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!_isCameraInitialized || _cameraController == null) return;

    if (state == AppLifecycleState.inactive) {
      _stopImageStream();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _startImageStream();
      }
    }
  }

  Future<void> _initializePoseDetector() async {
    try {
      debugPrint('🤖 Initializing pose detector...');

      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );

      setState(() {
        _poseDetectorInitialized = true;
        _formIssues = ['Pose detector ready! Position yourself in the camera.'];
      });

      debugPrint('✅ Pose detector initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing pose detector: $e');
      setState(() {
        _poseDetectorInitialized = false;
        _formIssues = ['Pose detection unavailable. Starting demo mode.'];
      });
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

  Future<void> _initializeCamera() async {
    try {
      debugPrint('📸 Initializing camera...');

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        debugPrint('❌ No cameras available');
        _handleCameraError('No cameras found on device');
        return;
      }

      await _selectCamera();

      debugPrint('✅ Camera initialized successfully');

      // Start image stream for pose detection
      await _startImageStream();
    } catch (e) {
      debugPrint('❌ Error initializing camera: $e');
      _handleCameraError('Camera initialization failed: ${e.toString()}');
    }
  }

  Future<void> _selectCamera() async {
    // Select front or back camera
    CameraDescription selectedCamera;
    try {
      selectedCamera = _cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (_isUsingFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras.first,
      );
      debugPrint(
        '📱 Using ${_isUsingFrontCamera ? 'front' : 'back'} camera: ${selectedCamera.name}',
      );
    } catch (e) {
      selectedCamera = _cameras.first;
      debugPrint('📱 Using first available camera: ${selectedCamera.name}');
    }

    // Dispose existing controller if it exists
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    // Initialize camera controller
    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high, // Higher resolution for better detection
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only one camera available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isUsingFrontCamera = !_isUsingFrontCamera;
    });

    // Voice announcement
    if (_voiceCoachEnabled && _voiceCoach != null) {
      _voiceCoach!.announceCameraSwitch(_isUsingFrontCamera);
    }

    // Stop current detection
    if (_isDetecting) {
      await _stopImageStream();
    }

    // Switch camera
    await _selectCamera();

    // Restart detection if it was running
    if (_isDetecting) {
      await _startImageStream();
    }
  }

  void _handleCameraError(String error) {
    setState(() {
      _isCameraInitialized = true; // Show fallback UI
      _formIssues = [error];
    });
  }

  Future<void> _startImageStream() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        !_poseDetectorInitialized ||
        _poseDetector == null) {
      debugPrint(
        '⚠️ Cannot start image stream - camera or pose detector not ready',
      );
      return;
    }

    try {
      debugPrint('🎬 Starting image stream...');
      _isDetecting = true;
      await _cameraController!.startImageStream(_processImage);
      debugPrint('✅ Image stream started successfully');

      setState(() {
        _formIssues = ['Camera active! Stand back and show your full body.'];
      });
    } catch (e) {
      debugPrint('❌ Error starting image stream: $e');
      setState(() {
        _formIssues = ['Error starting camera: $e'];
      });
    }
  }

  Future<void> _stopImageStream() async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      try {
        _isDetecting = false;
        await _cameraController!.stopImageStream();
        debugPrint('🛑 Image stream stopped');
      } catch (e) {
        debugPrint('❌ Error stopping image stream: $e');
      }
    }
  }

  void _processImage(CameraImage image) async {
    if (!_isWorkoutActive ||
        !_poseDetectorInitialized ||
        _isProcessingFrame ||
        _poseDetector == null ||
        _exerciseDetector == null) {
      return;
    }

    _isProcessingFrame = true;

    try {
      // Convert to InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        debugPrint('❌ Failed to convert camera image');
        _isProcessingFrame = false;
        return;
      }

      // Detect poses
      final List<Pose> poses = await _poseDetector!.processImage(inputImage);

      if (!mounted) {
        _isProcessingFrame = false;
        return;
      }

      if (poses.isEmpty) {
        setState(() {
          _poses = [];
          _exerciseMetrics = null;
          _formIssues = [
            'No pose detected. Move back and show your full body.',
          ];
        });
      } else {
        final pose = poses.first;

        // Analyze exercise
        final metrics = _exerciseDetector!.detectExercise(pose);
        debugPrint(
          '🎯 Exercise detection result: ${metrics?.repCount} reps, ${metrics?.feedback}',
        );

        // Voice coaching
        if (_voiceCoachEnabled && _voiceCoach != null && metrics != null) {
          await _voiceCoach!.analyzeExercise(metrics);
        }

        setState(() {
          _poses = poses;
          _exerciseMetrics = metrics;
          if (metrics != null) {
            _repCount = metrics.repCount;
            _formQuality = metrics.formScore / 100;
            _formIssues = [metrics.feedback];
          } else {
            _formIssues = ['Detecting exercise form...'];
          }
        });
      }
    } catch (e) {
      debugPrint('💥 Error processing image: $e');
      setState(() {
        _formIssues = ['Processing error: ${e.toString().substring(0, 50)}'];
      });
    } finally {
      _isProcessingFrame = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      var rotationCompensation = sensorOrientation;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + 180) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    _absoluteImageSize = Size(image.width.toDouble(), image.height.toDouble());

    // Get bytes from all planes
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // Create simplified metadata
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _endWorkout() async {
    if (!_isWorkoutActive) return;

    setState(() {
      _isWorkoutActive = false;
    });

    // Clean up resources
    _durationTimer?.cancel();
    _controlsTimer?.cancel();

    await _stopImageStream();

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
        averageHeartRate: 125,
        averageFormScore: _formQuality * 100,
      );

      // Save to Firebase
      await firebaseService.saveWorkoutSession(session);

      // Update gamification stats
      try {
        final gamificationResult =
            await WorkoutIntegrationService.onWorkoutCompleted(
              exerciseType: widget.exerciseName,
              repCount: _repCount,
              formScore: _formQuality * 100,
              durationMinutes: (_durationSeconds / 60).ceil(),
            );

        if (gamificationResult['success'] == true) {
          final xpEarned = gamificationResult['xpEarned'] as int;
          final newAchievements =
              gamificationResult['newAchievements'] as List<String>;
          final motivationMessage =
              WorkoutIntegrationService.getMotivationMessage(
                gamificationResult,
              );

          debugPrint('🎮 Gamification updated: +$xpEarned XP');
          if (newAchievements.isNotEmpty) {
            debugPrint('🏆 New achievements: ${newAchievements.join(", ")}');
          }

          // Show motivation message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(motivationMessage),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Gamification update failed: $e');
        // Continue without gamification if it fails
      }

      // Voice coach completion
      if (_voiceCoachEnabled && _voiceCoach != null) {
        await _voiceCoach!.announceWorkoutComplete(
          _repCount,
          _formQuality * 100,
        );
      }

      if (!mounted) return;

      // Restore system UI before leaving
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      // Navigate back with completion data including gamification results
      Navigator.pop(context, {
        'completed': true,
        'repCount': _repCount,
        'duration': _durationSeconds,
        'formScore': _formQuality * 100,
        'exerciseType': widget.exerciseName,
        'hasGamification': true,
      });
    } catch (e) {
      debugPrint('❌ Error saving workout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout completed! Reps: $_repCount'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, {'completed': true, 'repCount': _repCount});
      }
    }
  }

  int _calculateCaloriesBurned() {
    double mets = widget.workoutType.toLowerCase() == 'cardio' ? 6.0 : 4.5;
    int weightKg = 70;
    double durationHours = _durationSeconds / 3600;
    return (mets * weightKg * durationHours * 3.5).round();
  }

  void _resetExercise() {
    _exerciseDetector?.reset();
    if (_voiceCoachEnabled && _voiceCoach != null) {
      _voiceCoach!.announceReset();
    }
    setState(() {
      _exerciseMetrics = null;
      _repCount = 0;
      _formQuality = 0.75;
      _formIssues = ['Exercise reset. Ready to start!'];
    });
  }

  void _toggleVoiceCoach() {
    setState(() {
      _voiceCoachEnabled = !_voiceCoachEnabled;
    });

    if (_voiceCoach != null) {
      _voiceCoach!.setEnabled(_voiceCoachEnabled);

      if (_voiceCoachEnabled) {
        _voiceCoach!.testVoice();
      }
    }
  }

  void _onScreenTap() {
    if (_isFullScreen) {
      _resetControlsTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _controlsTimer?.cancel();

    _isDetecting = false;
    _stopImageStream();

    if (_cameraController != null) {
      _cameraController!.dispose();
    }

    _poseDetector?.close();
    _voiceCoach?.dispose();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onScreenTap,
        child: Stack(
          children: [
            // Full screen camera view
            Positioned.fill(
              child:
                  _isCameraInitialized
                      ? _buildCameraView()
                      : _buildLoadingScreen(),
            ),

            // Overlay controls (show/hide based on _showControls)
            if (_showControls) ...[
              // Top controls
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _buildTopControls(),
              ),

              // Bottom controls
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom,
                left: 0,
                right: 0,
                child: _buildBottomControls(),
              ),

              // Side controls
              Positioned(
                right: 16,
                top: MediaQuery.of(context).size.height * 0.3,
                child: _buildSideControls(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else
            _buildCameraPlaceholder(),

          // Form feedback overlay with all 33 keypoints
          if (_poses.isNotEmpty &&
              _absoluteImageSize != null &&
              _showFormFeedback)
            Positioned.fill(
              child: CustomPaint(
                painter: FormFeedbackPainter(
                  poses: _poses,
                  imageSize: _absoluteImageSize!,
                  rotation: _cameraController!.description.sensorOrientation,
                  lensDirection: _cameraController!.description.lensDirection,
                  exerciseMetrics: _exerciseMetrics,
                  showAngleIndicator: true,
                  showFormHighlight: true,
                  showAllKeypoints: _showAllKeypoints,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _poseDetectorInitialized ? 'Pose detection ready' : 'Demo mode',
              style: TextStyle(
                color: _poseDetectorInitialized ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera and pose detection...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _showExitDialog(),
          ),

          // Title
          Expanded(
            child: Text(
              '${widget.exerciseName} Workout',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Full screen toggle
          IconButton(
            icon: Icon(
              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: _toggleFullScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stats display
          _buildStatChip(
            icon: Icons.fitness_center,
            value: '$_repCount',
            label: 'Reps',
            color: Colors.blue,
          ),

          _buildStatChip(
            icon: Icons.timer,
            value: _formatDuration(_durationSeconds),
            label: 'Time',
            color: Colors.green,
          ),

          _buildStatChip(
            icon: Icons.local_fire_department,
            value: '${_calculateCaloriesBurned()}',
            label: 'Cal',
            color: Colors.orange,
          ),

          // End workout button
          ElevatedButton.icon(
            onPressed: _endWorkout,
            icon: const Icon(Icons.stop),
            label: const Text('End'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Column(
      children: [
        // Camera toggle
        FloatingActionButton(
          mini: true,
          heroTag: "camera_toggle",
          onPressed: _toggleCamera,
          backgroundColor: Colors.black.withOpacity(0.7),
          child: const Icon(Icons.flip_camera_ios, color: Colors.white),
        ),

        const SizedBox(height: 12),

        // Voice coach toggle
        FloatingActionButton(
          mini: true,
          heroTag: "voice_toggle",
          onPressed: _toggleVoiceCoach,
          backgroundColor:
              _voiceCoachEnabled
                  ? Colors.blue.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
          child: Icon(
            _voiceCoachEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        // Keypoints toggle
        FloatingActionButton(
          mini: true,
          heroTag: "keypoints_toggle",
          onPressed: () {
            setState(() {
              _showAllKeypoints = !_showAllKeypoints;
            });
          },
          backgroundColor:
              _showAllKeypoints
                  ? Colors.purple.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
          child: Icon(
            _showAllKeypoints ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 12),

        // Reset button
        FloatingActionButton(
          mini: true,
          heroTag: "reset",
          onPressed: _resetExercise,
          backgroundColor: Colors.orange.withOpacity(0.7),
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Workout?'),
          content: const Text(
            'Are you sure you want to end this workout session?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _endWorkout();
              },
              child: const Text('End Workout'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  ExerciseType _getExerciseTypeFromName(String exerciseName) {
    final name = exerciseName.toLowerCase().trim();
    debugPrint('🏷️ Mapping exercise name "$exerciseName" -> "$name"');

    if (name.contains('bicep') || name.contains('curl')) {
      debugPrint('✅ Mapped to ExerciseType.bicepCurl');
      return ExerciseType.bicepCurl;
    } else if (name.contains('pushup') ||
        name.contains('push-up') ||
        name.contains('push up')) {
      debugPrint('✅ Mapped to ExerciseType.pushup');
      return ExerciseType.pushup;
    } else if (name.contains('squat')) {
      debugPrint('✅ Mapped to ExerciseType.squat');
      return ExerciseType.squat;
    } else if (name.contains('arm circling') || name.contains('arm circle')) {
      debugPrint('✅ Mapped to ExerciseType.armCircling');
      return ExerciseType.armCircling;
    } else if (name.contains('shoulder press') || name.contains('press')) {
      debugPrint('✅ Mapped to ExerciseType.shoulderPress');
      return ExerciseType.shoulderPress;
    } else {
      // Default to bicep curl if not recognized
      debugPrint('⚠️ No match found, defaulting to ExerciseType.bicepCurl');
      return ExerciseType.bicepCurl;
    }
  }
}
