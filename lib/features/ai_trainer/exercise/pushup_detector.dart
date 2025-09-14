import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum PushupPhase { up, down, transition }

class PushupDetector {
  // Angle thresholds for pushup detection
  static const double EXTENDED_ELBOW_ANGLE =
      150.0; // Degrees when arms are extended
  static const double FLEXED_ELBOW_ANGLE = 90.0; // Degrees when at bottom
  static const double ANGLE_THRESHOLD = 20.0; // Tolerance for angle detection
  static const double MIN_BODY_ANGLE = 160.0; // Minimum body plank angle
  static const int HISTORY_SIZE = 5; // Frames to track for stability
  static const int MIN_REP_TIME = 30; // Minimum frames between reps

  // State tracking
  PushupPhase _currentPhase = PushupPhase.up;
  int _repCount = 0;
  int _framesSinceLastRep = 0;
  final List<double> _elbowAngleHistory = [];
  final List<double> _bodyAngleHistory = [];

  // Form quality tracking
  double _formQuality = 0.75;
  final List<String> _formIssues = [];

  int get repCount => _repCount;
  PushupPhase get currentPhase => _currentPhase;
  double get formQuality => _formQuality;
  List<String> get formIssues => List.from(_formIssues);

  void reset() {
    _currentPhase = PushupPhase.up;
    _repCount = 0;
    _framesSinceLastRep = 0;
    _elbowAngleHistory.clear();
    _bodyAngleHistory.clear();
    _formQuality = 0.75;
    _formIssues.clear();
  }

  bool detectPushup(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return false;

    _framesSinceLastRep++;
    _formIssues.clear();

    // Get required landmarks
    final leftShoulder = _getLandmark(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = _getLandmark(
      landmarks,
      PoseLandmarkType.rightShoulder,
    );
    final leftElbow = _getLandmark(landmarks, PoseLandmarkType.leftElbow);
    final rightElbow = _getLandmark(landmarks, PoseLandmarkType.rightElbow);
    final leftWrist = _getLandmark(landmarks, PoseLandmarkType.leftWrist);
    final rightWrist = _getLandmark(landmarks, PoseLandmarkType.rightWrist);
    final leftHip = _getLandmark(landmarks, PoseLandmarkType.leftHip);
    final rightHip = _getLandmark(landmarks, PoseLandmarkType.rightHip);
    final leftAnkle = _getLandmark(landmarks, PoseLandmarkType.leftAnkle);
    final rightAnkle = _getLandmark(landmarks, PoseLandmarkType.rightAnkle);

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftHip == null ||
        rightHip == null ||
        leftAnkle == null ||
        rightAnkle == null) {
      _formIssues.add('Position yourself so your full body is visible');
      return false;
    }

    // Calculate angles
    double leftElbowAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightElbowAngle = _calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    double avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    // Calculate body alignment (plank position)
    double leftBodyAngle = _calculateAngle(leftShoulder, leftHip, leftAnkle);
    double rightBodyAngle = _calculateAngle(
      rightShoulder,
      rightHip,
      rightAnkle,
    );
    double avgBodyAngle = (leftBodyAngle + rightBodyAngle) / 2;

    // Update history
    _elbowAngleHistory.add(avgElbowAngle);
    _bodyAngleHistory.add(avgBodyAngle);
    if (_elbowAngleHistory.length > HISTORY_SIZE) {
      _elbowAngleHistory.removeAt(0);
    }
    if (_bodyAngleHistory.length > HISTORY_SIZE) {
      _bodyAngleHistory.removeAt(0);
    }

    // Analyze form quality
    _analyzeForm(
      avgElbowAngle,
      avgBodyAngle,
      leftShoulder,
      rightShoulder,
      leftWrist,
      rightWrist,
    );

    // Detect pushup phases
    return _detectPhaseTransition(avgElbowAngle);
  }

  PoseLandmark? _getLandmark(
    List<PoseLandmark> landmarks,
    PoseLandmarkType type,
  ) {
    try {
      return landmarks.firstWhere((landmark) => landmark.type == type);
    } catch (e) {
      return null;
    }
  }

  double _calculateAngle(
    PoseLandmark point1,
    PoseLandmark point2,
    PoseLandmark point3,
  ) {
    // Calculate angle at point2 using vectors to point1 and point3
    double vector1X = point1.x - point2.x;
    double vector1Y = point1.y - point2.y;
    double vector2X = point3.x - point2.x;
    double vector2Y = point3.y - point2.y;

    double dotProduct = vector1X * vector2X + vector1Y * vector2Y;
    double magnitude1 = sqrt(vector1X * vector1X + vector1Y * vector1Y);
    double magnitude2 = sqrt(vector2X * vector2X + vector2Y * vector2Y);

    if (magnitude1 == 0 || magnitude2 == 0) return 0;

    double cosAngle = dotProduct / (magnitude1 * magnitude2);
    cosAngle = cosAngle.clamp(-1.0, 1.0);

    return acos(cosAngle) * 180 / pi;
  }

  void _analyzeForm(
    double elbowAngle,
    double bodyAngle,
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
  ) {
    double quality = 1.0;

    // Check body alignment (plank position)
    if (bodyAngle < MIN_BODY_ANGLE) {
      _formIssues.add('Keep your body in a straight line - avoid sagging hips');
      quality -= 0.3;
    }

    // Check hand position width
    double handDistance = sqrt(
      pow(leftWrist.x - rightWrist.x, 2) + pow(leftWrist.y - rightWrist.y, 2),
    );
    double shoulderDistance = sqrt(
      pow(leftShoulder.x - rightShoulder.x, 2) +
          pow(leftShoulder.y - rightShoulder.y, 2),
    );

    double handWidthRatio = handDistance / shoulderDistance;
    if (handWidthRatio < 1.2 || handWidthRatio > 2.0) {
      _formIssues.add(
        'Adjust hand width - should be slightly wider than shoulders',
      );
      quality -= 0.2;
    }

    // Check for controlled movement
    if (_elbowAngleHistory.length >= 3) {
      double angleVariation = _calculateVariation(_elbowAngleHistory);
      if (angleVariation > 30) {
        _formIssues.add('Move more slowly and controlled');
        quality -= 0.15;
      }
    }

    // Update form quality with smoothing
    quality = quality.clamp(0.0, 1.0);
    _formQuality = _formQuality * 0.7 + quality * 0.3;
    _formQuality = _formQuality.clamp(0.0, 1.0);
  }

  double _calculateVariation(List<double> values) {
    if (values.length < 2) return 0;

    double sum = values.reduce((a, b) => a + b);
    double mean = sum / values.length;

    double variance =
        values.map((value) => pow(value - mean, 2)).reduce((a, b) => a + b) /
        values.length;

    return sqrt(variance);
  }

  bool _detectPhaseTransition(double elbowAngle) {
    if (_framesSinceLastRep < MIN_REP_TIME) return false;

    switch (_currentPhase) {
      case PushupPhase.up:
        // Look for transition to down phase
        if (elbowAngle < FLEXED_ELBOW_ANGLE + ANGLE_THRESHOLD) {
          _currentPhase = PushupPhase.down;
        }
        break;

      case PushupPhase.down:
        // Look for transition back to up phase (complete rep)
        if (elbowAngle > EXTENDED_ELBOW_ANGLE - ANGLE_THRESHOLD) {
          _currentPhase = PushupPhase.up;
          _repCount++;
          _framesSinceLastRep = 0;
          return true; // Rep completed
        }
        break;

      case PushupPhase.transition:
        // Handle transition state if needed
        break;
    }

    return false;
  }

  FormQuality getFormQualityLevel() {
    if (_formQuality >= 0.85) return FormQuality.excellent;
    if (_formQuality >= 0.70) return FormQuality.good;
    if (_formQuality >= 0.50) return FormQuality.fair;
    return FormQuality.poor;
  }
}

enum FormQuality { excellent, good, fair, poor }
