// Create a new file: lib/features/ai_trainer/services/pose_analyzer_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart' show WriteBuffer, debugPrint, kIsWeb;

/// Result class for pose analysis
class PoseAnalysisResult {
  final int repCount;
  final double formQuality;
  final List<String> formIssues;
  final List<PoseLandmark>? landmarks;

  PoseAnalysisResult({
    required this.repCount,
    required this.formQuality,
    required this.formIssues,
    this.landmarks,
  });
}

/// Service for analyzing exercise pose and form
class PoseAnalyzerService {
  // Pose detector
  late PoseDetector _poseDetector;
  bool _isInitialized = false;

  // Tracking state
  int _repCount = 0;
  double _formQualitySum = 0.0;
  int _formQualityCount = 0;
  bool _wasInBottomPosition = false;
  bool _wasInTopPosition = true; // Start in top position

  // Exercise-specific settings
  Map<String, dynamic> _exerciseSettings = {};

  // Current exercise
  String _currentExercise = '';

  // Form issues
  final List<String> _currentFormIssues = [];

  /// Initialize the service with the exercise name
  Future<void> initialize(String exerciseName) async {
    // Set current exercise
    _currentExercise = exerciseName;

    // Initialize pose detector
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );

    // Set exercise-specific settings
    _setupExerciseSettings(exerciseName);

    _isInitialized = true;
  }

  /// Set up the settings for specific exercises
  void _setupExerciseSettings(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'squat':
        _exerciseSettings = {
          'repThresholds': {
            'bottom': 0.65, // Lower position threshold
            'top': 0.45, // Upper position threshold
          },
          'formChecks': ['kneeAngle', 'hipAngle', 'backStraight'],
          'feedbackMessages': {
            'kneeAngle': 'Bend your knees more for proper depth',
            'hipAngle': 'Lower your hips more for full range of motion',
            'backStraight': 'Keep your back straight throughout the movement',
          },
        };
        break;

      case 'pushup':
        _exerciseSettings = {
          'repThresholds': {
            'bottom': 0.6, // Lower position threshold
            'top': 0.45, // Upper position threshold
          },
          'formChecks': ['elbowAngle', 'bodyAlignment', 'headPosition'],
          'feedbackMessages': {
            'elbowAngle': 'Bend your elbows more for proper depth',
            'bodyAlignment': 'Maintain a straight line from head to heels',
            'headPosition': 'Keep your neck in a neutral position',
          },
        };
        break;

      default:
        // Default settings
        _exerciseSettings = {
          'repThresholds': {'bottom': 0.6, 'top': 0.4},
          'formChecks': ['generalForm'],
          'feedbackMessages': {
            'generalForm': 'Maintain proper form throughout the exercise',
          },
        };
        break;
    }
  }

  /// Process a camera image and analyze the pose
  Future<PoseAnalysisResult?> processFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (!_isInitialized) return null;

    try {
      // For web, we'll simulate results since camera processing is different
      if (kIsWeb) {
        return simulateResults();
      }

      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImageToInputImage(image, camera);

      // Process the image to detect poses
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        return PoseAnalysisResult(
          repCount: _repCount,
          formQuality: 0.0,
          formIssues: [
            'No pose detected. Make sure your full body is visible.',
          ],
        );
      }

      // Analyze the main pose (first detected pose)
      final pose = poses.first;
      final landmarks = pose.landmarks.values.toList();

      // Analyze form based on exercise type
      final analysisResults = _analyzeExerciseForm(landmarks, _currentExercise);

      // Update rep count
      _updateRepCount(analysisResults['position'] as double);

      // Update form quality
      _formQualitySum += analysisResults['formQuality'] as double;
      _formQualityCount++;

      // Get current form issues
      _currentFormIssues.clear();
      for (var issue in analysisResults['formIssues'] as List) {
        if (_exerciseSettings['feedbackMessages'].containsKey(issue)) {
          _currentFormIssues.add(_exerciseSettings['feedbackMessages'][issue]);
        }
      }

      return PoseAnalysisResult(
        repCount: _repCount,
        formQuality: analysisResults['formQuality'] as double,
        formIssues:
            _currentFormIssues.isEmpty
                ? ['Good form! Keep it up.']
                : _currentFormIssues,
        landmarks: landmarks,
      );
    } catch (e) {
      debugPrint('Error analyzing pose: $e');
      return PoseAnalysisResult(
        repCount: _repCount,
        formQuality: 0.0,
        formIssues: ['Error analyzing pose. Please try again.'],
      );
    }
  }

  // Simulate results for web demo
  PoseAnalysisResult simulateResults() {
    // Create simulated landmarks for visualization
    final simLandmarks = <PoseLandmark>[];

    // Return simulated result
    return PoseAnalysisResult(
      repCount: _repCount,
      formQuality: 0.75,
      formIssues: ['Web demo mode - actual pose analysis disabled'],
      landmarks: simLandmarks,
    );
  }

  /// Convert CameraImage to InputImage
  /*
  InputImage _convertCameraImageToInputImage(
    CameraImage image, 
    CameraDescription camera
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    
    final imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
    
    final inputImageRotation = InputImageRotation.values[
      (camera.sensorOrientation ~/ 90) % 4
    ];
    
    const inputImageFormat = InputImageFormat.nv21; // Most common format
    
    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();
    
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: inputImageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    
    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );
  }
  */

  /// Convert CameraImage to InputImage- v2
  ///
  /*
InputImage _convertCameraImageToInputImage(
  CameraImage image, 
  CameraDescription camera
) {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();
  
  final imageSize = ui.Size(image.width.toDouble(), image.height.toDouble());
  
  // Get proper rotation
  final inputImageRotation = InputImageRotation.values[
    (camera.sensorOrientation ~/ 90) % 4
  ];
  
  // For most cameras, this format works
  final inputImageFormat = InputImageFormat.yuv420;
  
  final planeData = image.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();
  
  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: inputImageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );
  
  return InputImage.fromBytes(
    bytes: bytes,
    inputImageData: inputImageData,
  );
}

*/

  /// Analyze exercise form based on landmarks
  Map<String, dynamic> _analyzeExerciseForm(
    List<PoseLandmark> landmarks, 
    String exerciseType
  ) {
    switch (exerciseType.toLowerCase()) {
      case 'squat':
        return _analyzeSquat(landmarks);
      case 'pushup':
        return _analyzePushup(landmarks);
      default:
        // Default analysis
        return {
          'position': 0.5, // Neutral position
          'formQuality': 0.8, // Default quality
          'formIssues': [], // No specific issues
        };
    }
  }

  /// Convert CameraImage to InputImage- v3
  ///
  InputImage _convertCameraImageToInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    // Try different approaches based on the image format
    try {
      // First approach - try with yuv420
      final inputImageFormat = InputImageFormat.yuv420;

      // Calculate rotation
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      // Get image dimensions
      final width = image.width;
      final height = image.height;

      // Create plane data
      final planeData =
          image.planes.map((Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          }).toList();

      // Package image data
      final inputImageData = InputImageData(
        size: ui.Size(width.toDouble(), height.toDouble()),
        imageRotation: rotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      // Concatenate all plane bytes - important for proper format
      final allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Create input image
      return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    } catch (e) {
      debugPrint('Error converting image: $e');
      rethrow;
    }
  }

  /// Analyze squat form
  Map<String, dynamic> _analyzeSquat(List<PoseLandmark> landmarks) {
    // Find specific landmarks by their type
    final leftHip = _findLandmarkByType(landmarks, PoseLandmarkType.leftHip);
    final rightHip = _findLandmarkByType(landmarks, PoseLandmarkType.rightHip);
    final leftKnee = _findLandmarkByType(landmarks, PoseLandmarkType.leftKnee);
    final rightKnee = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightKnee,
    );
    final leftAnkle = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.leftAnkle,
    );
    final rightAnkle = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightAnkle,
    );
    final leftShoulder = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.leftShoulder,
    );
    final rightShoulder = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightShoulder,
    );

    // If missing critical landmarks, return basic info
    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return {
        'position': 0.5,
        'formQuality': 0.5,
        'formIssues': ['bodyNotFullyVisible'],
      };
    }

    // Calculate relative position (0 = standing straight, 1 = deep squat)
    // Use the y-coordinate of hips relative to knees and ankles
    final hipY = (leftHip.y + rightHip.y) / 2;
    final kneeY = (leftKnee.y + rightKnee.y) / 2;
    final ankleY = (leftAnkle.y + rightAnkle.y) / 2;

    // Normalize the hip position between knees and shoulders
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final totalHeight = shoulderY - ankleY;

    // Calculate relative squat depth (0 = standing, 1 = deep squat)
    double position = (hipY - shoulderY) / totalHeight;
    position = position.clamp(0.0, 1.0);

    // Check for form issues
    List<String> formIssues = [];

    // Check knee alignment (knees should be aligned with ankles)
    final leftKneeAnkleXDiff = (leftKnee.x - leftAnkle.x).abs();
    final rightKneeAnkleXDiff = (rightKnee.x - rightAnkle.x).abs();

    if (leftKneeAnkleXDiff > 0.1 || rightKneeAnkleXDiff > 0.1) {
      formIssues.add('kneeAngle');
    }

    // Check hip depth (for deep enough squat)
    if (position < 0.4 && _wasInBottomPosition) {
      formIssues.add('hipAngle');
    }

    // Check back alignment
    final shoulderHipXDiff =
        ((leftShoulder.x + rightShoulder.x) / 2 - (leftHip.x + rightHip.x) / 2)
            .abs();
    if (shoulderHipXDiff > 0.1) {
      formIssues.add('backStraight');
    }

    // Calculate form quality (0.0 to 1.0)
    double formQuality = 1.0;
    if (formIssues.contains('kneeAngle')) formQuality -= 0.3;
    if (formIssues.contains('hipAngle')) formQuality -= 0.3;
    if (formIssues.contains('backStraight')) formQuality -= 0.4;

    return {
      'position': position,
      'formQuality': formQuality.clamp(0.0, 1.0),
      'formIssues': formIssues,
    };
  }

  /// Analyze pushup form
  Map<String, dynamic> _analyzePushup(List<PoseLandmark> landmarks) {
    // Find specific landmarks by their type
    final leftShoulder = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.leftShoulder,
    );
    final rightShoulder = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightShoulder,
    );
    final leftElbow = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.leftElbow,
    );
    final rightElbow = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightElbow,
    );
    final leftWrist = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.leftWrist,
    );
    final rightWrist = _findLandmarkByType(
      landmarks,
      PoseLandmarkType.rightWrist,
    );
    final nose = _findLandmarkByType(landmarks, PoseLandmarkType.nose);
    final leftHip = _findLandmarkByType(landmarks, PoseLandmarkType.leftHip);
    final rightHip = _findLandmarkByType(landmarks, PoseLandmarkType.rightHip);

    // Ensure all required landmarks are detected
    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        nose == null ||
        leftHip == null ||
        rightHip == null) {
      return {
        'position': 0.5,
        'formQuality': 0.5,
        'formIssues': ['bodyNotFullyVisible'],
      };
    }

    // Calculate elbow angle
    double leftElbowAngle = _calculateAngle(
      leftShoulder.x,
      leftShoulder.y,
      leftElbow.x,
      leftElbow.y,
      leftWrist.x,
      leftWrist.y,
    );

    double rightElbowAngle = _calculateAngle(
      rightShoulder.x,
      rightShoulder.y,
      rightElbow.x,
      rightElbow.y,
      rightWrist.x,
      rightWrist.y,
    );

    double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Normalize position between 0 (arms extended) and 1 (arms bent)
    double position = (180 - avgElbowAngle) / 90;
    position = position.clamp(0.0, 1.0);

    // Check for form issues
    List<String> formIssues = [];

    // Check elbow angle (should be approximately 90 degrees at bottom position)
    if (position > 0.6 && (avgElbowAngle < 70 || avgElbowAngle > 110)) {
      formIssues.add('elbowAngle');
    }

    // Check body alignment (head, shoulders, hips, knees, ankles should be in line)
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipY = (leftHip.y + rightHip.y) / 2;

    if ((shoulderY - hipY).abs() > 0.1) {
      formIssues.add('bodyAlignment');
    }

    // Check head position (should be in line with body)
    final shoulderX = (leftShoulder.x + rightShoulder.x) / 2;
    if ((nose.x - shoulderX).abs() > 0.1) {
      formIssues.add('headPosition');
    }

    // Calculate form quality
    double formQuality = 1.0;
    if (formIssues.contains('elbowAngle')) formQuality -= 0.3;
    if (formIssues.contains('bodyAlignment')) formQuality -= 0.4;
    if (formIssues.contains('headPosition')) formQuality -= 0.3;

    return {
      'position': position,
      'formQuality': formQuality.clamp(0.0, 1.0),
      'formIssues': formIssues,
    };
  }

  /// Helper method to find a landmark by its type in the list
  PoseLandmark? _findLandmarkByType(
    List<PoseLandmark> landmarks,
    PoseLandmarkType type,
  ) {
    try {
      return landmarks.firstWhere((landmark) => landmark.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Calculate the angle between three points
  double _calculateAngle(
    double ax,
    double ay,
    double bx,
    double by,
    double cx,
    double cy,
  ) {
    final abx = bx - ax;
    final aby = by - ay;
    final cbx = bx - cx;
    final cby = by - cy;

    final dot = abx * cbx + aby * cby;
    final abMag = math.sqrt(abx * abx + aby * aby);
    final cbMag = math.sqrt(cbx * cbx + cby * cby);

    final cosTheta = dot / (abMag * cbMag);

    return math.acos(cosTheta.clamp(-1.0, 1.0)) * 180 / math.pi;
  }

  /// Update rep count based on position
  void _updateRepCount(double position) {
    // Get thresholds from settings
    final bottomThreshold = _exerciseSettings['repThresholds']['bottom'];
    final topThreshold = _exerciseSettings['repThresholds']['top'];

    // Check if user moved to bottom position
    if (position >= bottomThreshold &&
        !_wasInBottomPosition &&
        _wasInTopPosition) {
      _wasInBottomPosition = true;
      _wasInTopPosition = false;
    }

    // Check if user returned to top position
    if (position <= topThreshold &&
        _wasInBottomPosition &&
        !_wasInTopPosition) {
      _wasInBottomPosition = false;
      _wasInTopPosition = true;
      // Increment rep count
      _repCount++;
    }
  }

  /// Calculate form quality (0.0 to 1.0)
  double _calculateFormQuality() {
    if (_formQualityCount == 0) return 0.0;
    return _formQualitySum / _formQualityCount;
  }

  /// Reset rep counter
  void resetRepCounter() {
    _repCount = 0;
    _wasInBottomPosition = false;
    _wasInTopPosition = true;
  }

  /// Reset form quality tracking
  void resetFormQuality() {
    _formQualitySum = 0.0;
    _formQualityCount = 0;
  }

  /// Dispose resources
  void dispose() {
    _poseDetector.close();
  }
}
