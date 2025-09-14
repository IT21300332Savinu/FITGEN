// lib/features/ai_trainer/services/pose_analyzer_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/foundation.dart';

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
  bool _wasInBottomPosition = false;
  bool _wasInTopPosition = true;

  // Exercise-specific settings
  Map<String, dynamic> _exerciseSettings = {};
  String _currentExercise = '';
  final List<String> _currentFormIssues = [];

  // Processing control
  bool _isProcessing = false;

  /// Initialize the service with the exercise name
  Future<void> initialize(String exerciseName) async {
    try {
      _currentExercise = exerciseName;

      // Initialize pose detector with v0.6.0 API
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );

      _setupExerciseSettings(exerciseName);
      _isInitialized = true;
      debugPrint('Pose analyzer initialized for: $exerciseName');
    } catch (e) {
      debugPrint('Error initializing pose analyzer: $e');
      rethrow;
    }
  }

  /// Set up exercise-specific settings
  void _setupExerciseSettings(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'squat':
        _exerciseSettings = {
          'repThresholds': {
            'bottom': 0.65,
            'top': 0.45,
          },
          'formChecks': ['kneeAngle', 'hipAngle', 'backStraight'],
          'feedbackMessages': {
            'kneeAngle': 'Keep your knees aligned with your toes',
            'hipAngle': 'Lower your hips more for full range of motion',
            'backStraight': 'Keep your back straight throughout the movement',
            'bodyNotFullyVisible': 'Make sure your full body is visible in the camera',
          },
        };
        break;

      case 'pushup':
        _exerciseSettings = {
          'repThresholds': {
            'bottom': 0.6,
            'top': 0.45,
          },
          'formChecks': ['elbowAngle', 'bodyAlignment', 'headPosition'],
          'feedbackMessages': {
            'elbowAngle': 'Bend your elbows more for proper depth',
            'bodyAlignment': 'Maintain a straight line from head to heels',
            'headPosition': 'Keep your neck in a neutral position',
            'bodyNotFullyVisible': 'Position yourself so your full body is visible',
          },
        };
        break;

      default:
        _exerciseSettings = {
          'repThresholds': {'bottom': 0.6, 'top': 0.4},
          'formChecks': ['generalForm'],
          'feedbackMessages': {
            'generalForm': 'Maintain proper form throughout the exercise',
            'bodyNotFullyVisible': 'Make sure you are fully visible in the camera',
          },
        };
    }
  }

  /// Process a camera image and analyze the pose
  Future<PoseAnalysisResult?> processFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (!_isInitialized || _isProcessing) return null;

    _isProcessing = true;
    
    try {
      // Convert CameraImage to InputImage using v0.6.0 API
      final inputImage = _convertCameraImageToInputImage(image, camera);
      if (inputImage == null) {
        _isProcessing = false;
        return _createErrorResult('Failed to process camera image');
      }

      // Process the image to detect poses
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        _isProcessing = false;
        return PoseAnalysisResult(
          repCount: _repCount,
          formQuality: 0.0,
          formIssues: ['No pose detected. Make sure your full body is visible.'],
        );
      }

      // Analyze the main pose
      final pose = poses.first;
      final landmarks = pose.landmarks.values.toList();

      // Analyze form based on exercise type
      final analysisResults = _analyzeExerciseForm(landmarks, _currentExercise);

      // Update rep count
      _updateRepCount(analysisResults['position'] as double);

      // Get form quality for this frame
      final currentFormQuality = analysisResults['formQuality'] as double;

      // Get current form issues
      _currentFormIssues.clear();
      final formIssues = analysisResults['formIssues'] as List<String>;
      for (var issue in formIssues) {
        if (_exerciseSettings['feedbackMessages'].containsKey(issue)) {
          _currentFormIssues.add(_exerciseSettings['feedbackMessages'][issue]);
        }
      }

      _isProcessing = false;

      return PoseAnalysisResult(
        repCount: _repCount,
        formQuality: currentFormQuality,
        formIssues: _currentFormIssues.isEmpty 
            ? ['Good form! Keep it up.'] 
            : _currentFormIssues,
        landmarks: landmarks,
      );

    } catch (e) {
      _isProcessing = false;
      debugPrint('Error analyzing pose: $e');
      return _createErrorResult('Error analyzing pose: ${e.toString()}');
    }
  }

  /// Convert CameraImage to InputImage (v0.6.0 compatible)
  InputImage? _convertCameraImageToInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    try {
      // Get image rotation
      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      if (rotation == null) {
        debugPrint('Failed to get rotation value');
        return null;
      }

      // Get image format
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) {
        debugPrint('Unsupported image format: ${image.format.raw}');
        return null;
      }

      // Create simplified metadata
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      // Get bytes from all planes
      final allBytes = <int>[];
      for (final plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }

      return InputImage.fromBytes(
        bytes: Uint8List.fromList(allBytes),
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  /// Create error result
  PoseAnalysisResult _createErrorResult(String message) {
    return PoseAnalysisResult(
      repCount: _repCount,
      formQuality: 0.0,
      formIssues: [message],
    );
  }

  /// Analyze exercise form based on landmarks
  Map<String, dynamic> _analyzeExerciseForm(
    List<PoseLandmark> landmarks,
    String exerciseType,
  ) {
    switch (exerciseType.toLowerCase()) {
      case 'squat':
        return _analyzeSquat(landmarks);
      case 'pushup':
        return _analyzePushup(landmarks);
      default:
        return {
          'position': 0.5,
          'formQuality': 0.8,
          'formIssues': <String>[],
        };
    }
  }

  /// Analyze squat form
  Map<String, dynamic> _analyzeSquat(List<PoseLandmark> landmarks) {
    final requiredLandmarks = {
      'leftHip': _findLandmarkByType(landmarks, PoseLandmarkType.leftHip),
      'rightHip': _findLandmarkByType(landmarks, PoseLandmarkType.rightHip),
      'leftKnee': _findLandmarkByType(landmarks, PoseLandmarkType.leftKnee),
      'rightKnee': _findLandmarkByType(landmarks, PoseLandmarkType.rightKnee),
      'leftAnkle': _findLandmarkByType(landmarks, PoseLandmarkType.leftAnkle),
      'rightAnkle': _findLandmarkByType(landmarks, PoseLandmarkType.rightAnkle),
      'leftShoulder': _findLandmarkByType(landmarks, PoseLandmarkType.leftShoulder),
      'rightShoulder': _findLandmarkByType(landmarks, PoseLandmarkType.rightShoulder),
    };

    // Check if all required landmarks are detected
    if (requiredLandmarks.values.any((landmark) => landmark == null)) {
      return {
        'position': 0.5,
        'formQuality': 0.5,
        'formIssues': ['bodyNotFullyVisible'],
      };
    }

    final leftHip = requiredLandmarks['leftHip']!;
    final rightHip = requiredLandmarks['rightHip']!;
    final leftKnee = requiredLandmarks['leftKnee']!;
    final rightKnee = requiredLandmarks['rightKnee']!;
    final leftAnkle = requiredLandmarks['leftAnkle']!;
    final rightAnkle = requiredLandmarks['rightAnkle']!;
    final leftShoulder = requiredLandmarks['leftShoulder']!;
    final rightShoulder = requiredLandmarks['rightShoulder']!;

    // Calculate relative position
    final hipY = (leftHip.y + rightHip.y) / 2;
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final ankleY = (leftAnkle.y + rightAnkle.y) / 2;

    // Calculate squat depth (0 = standing, 1 = deep squat)
    final totalHeight = shoulderY - ankleY;
    double position = totalHeight > 0 ? (hipY - shoulderY) / totalHeight : 0.0;
    position = position.clamp(0.0, 1.0);

    // Check form issues
    List<String> formIssues = [];

    // Check knee alignment
    final leftKneeAnkleXDiff = (leftKnee.x - leftAnkle.x).abs();
    final rightKneeAnkleXDiff = (rightKnee.x - rightAnkle.x).abs();
    if (leftKneeAnkleXDiff > 0.1 || rightKneeAnkleXDiff > 0.1) {
      formIssues.add('kneeAngle');
    }

    // Check squat depth
    if (position < 0.4 && _wasInBottomPosition) {
      formIssues.add('hipAngle');
    }

    // Check back alignment
    final shoulderHipXDiff = ((leftShoulder.x + rightShoulder.x) / 2 - 
                             (leftHip.x + rightHip.x) / 2).abs();
    if (shoulderHipXDiff > 0.1) {
      formIssues.add('backStraight');
    }

    // Calculate form quality
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
    final requiredLandmarks = {
      'leftShoulder': _findLandmarkByType(landmarks, PoseLandmarkType.leftShoulder),
      'rightShoulder': _findLandmarkByType(landmarks, PoseLandmarkType.rightShoulder),
      'leftElbow': _findLandmarkByType(landmarks, PoseLandmarkType.leftElbow),
      'rightElbow': _findLandmarkByType(landmarks, PoseLandmarkType.rightElbow),
      'leftWrist': _findLandmarkByType(landmarks, PoseLandmarkType.leftWrist),
      'rightWrist': _findLandmarkByType(landmarks, PoseLandmarkType.rightWrist),
      'nose': _findLandmarkByType(landmarks, PoseLandmarkType.nose),
      'leftHip': _findLandmarkByType(landmarks, PoseLandmarkType.leftHip),
      'rightHip': _findLandmarkByType(landmarks, PoseLandmarkType.rightHip),
    };

    if (requiredLandmarks.values.any((landmark) => landmark == null)) {
      return {
        'position': 0.5,
        'formQuality': 0.5,
        'formIssues': ['bodyNotFullyVisible'],
      };
    }

    final leftShoulder = requiredLandmarks['leftShoulder']!;
    final rightShoulder = requiredLandmarks['rightShoulder']!;
    final leftElbow = requiredLandmarks['leftElbow']!;
    final rightElbow = requiredLandmarks['rightElbow']!;
    final leftWrist = requiredLandmarks['leftWrist']!;
    final rightWrist = requiredLandmarks['rightWrist']!;
    final nose = requiredLandmarks['nose']!;
    final leftHip = requiredLandmarks['leftHip']!;
    final rightHip = requiredLandmarks['rightHip']!;

    // Calculate elbow angles
    final leftElbowAngle = _calculateAngle(
      leftShoulder.x, leftShoulder.y,
      leftElbow.x, leftElbow.y,
      leftWrist.x, leftWrist.y,
    );

    final rightElbowAngle = _calculateAngle(
      rightShoulder.x, rightShoulder.y,
      rightElbow.x, rightElbow.y,
      rightWrist.x, rightWrist.y,
    );

    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;
    double position = (180 - avgElbowAngle) / 90;
    position = position.clamp(0.0, 1.0);

    // Check form issues
    List<String> formIssues = [];

    // Check elbow angle
    if (position > 0.6 && (avgElbowAngle < 70 || avgElbowAngle > 110)) {
      formIssues.add('elbowAngle');
    }

    // Check body alignment
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipY = (leftHip.y + rightHip.y) / 2;
    if ((shoulderY - hipY).abs() > 0.1) {
      formIssues.add('bodyAlignment');
    }

    // Check head position
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

  /// Helper method to find a landmark by its type
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

  /// Calculate angle between three points
  double _calculateAngle(double ax, double ay, double bx, double by, double cx, double cy) {
    final abx = bx - ax;
    final aby = by - ay;
    final cbx = bx - cx;
    final cby = by - cy;

    final dot = abx * cbx + aby * cby;
    final abMag = math.sqrt(abx * abx + aby * aby);
    final cbMag = math.sqrt(cbx * cbx + cby * cby);

    if (abMag == 0 || cbMag == 0) return 0;

    final cosTheta = (dot / (abMag * cbMag)).clamp(-1.0, 1.0);
    return math.acos(cosTheta) * 180 / math.pi;
  }

  /// Update rep count based on position
  void _updateRepCount(double position) {
    final bottomThreshold = _exerciseSettings['repThresholds']['bottom'] as double;
    final topThreshold = _exerciseSettings['repThresholds']['top'] as double;

    if (position >= bottomThreshold && !_wasInBottomPosition && _wasInTopPosition) {
      _wasInBottomPosition = true;
      _wasInTopPosition = false;
    }

    if (position <= topThreshold && _wasInBottomPosition && !_wasInTopPosition) {
      _wasInBottomPosition = false;
      _wasInTopPosition = true;
      _repCount++;
    }
  }

  /// Reset counters
  void resetCounters() {
    _repCount = 0;
    _wasInBottomPosition = false;
    _wasInTopPosition = true;
    _currentFormIssues.clear();
  }

  /// Dispose resources
  void dispose() {
    if (_isInitialized) {
      _poseDetector.close();
    }
  }
}