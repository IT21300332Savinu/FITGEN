import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum ShoulderPressPhase { bottom, top, transition }

class ShoulderPressDetector {
  // Angle thresholds for shoulder press detection
  static const double BOTTOM_ARM_ANGLE = 90.0; // Degrees when arms at bottom
  static const double TOP_ARM_ANGLE = 170.0; // Degrees when arms pressed up
  static const double ANGLE_THRESHOLD = 15.0; // Tolerance for angle detection
  static const double MIN_ELEVATION_ANGLE = 60.0; // Minimum shoulder elevation
  static const double MAX_FORWARD_LEAN = 0.1; // Max forward lean ratio
  static const int HISTORY_SIZE = 5; // Frames to track for stability
  static const int MIN_REP_TIME = 30; // Minimum frames between reps

  // State tracking
  ShoulderPressPhase _currentPhase = ShoulderPressPhase.bottom;
  int _repCount = 0;
  int _framesSinceLastRep = 0;
  final List<double> _armAngleHistory = [];
  final List<double> _shoulderElevationHistory = [];

  // Form quality tracking
  double _formQuality = 0.75;
  final List<String> _formIssues = [];

  int get repCount => _repCount;
  ShoulderPressPhase get currentPhase => _currentPhase;
  double get formQuality => _formQuality;
  List<String> get formIssues => List.from(_formIssues);

  void reset() {
    _currentPhase = ShoulderPressPhase.bottom;
    _repCount = 0;
    _framesSinceLastRep = 0;
    _armAngleHistory.clear();
    _shoulderElevationHistory.clear();
    _formQuality = 0.75;
    _formIssues.clear();
  }

  bool detectShoulderPress(List<PoseLandmark> landmarks) {
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
    final nose = _getLandmark(landmarks, PoseLandmarkType.nose);

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftElbow == null ||
        rightElbow == null ||
        leftWrist == null ||
        rightWrist == null ||
        leftHip == null ||
        rightHip == null ||
        nose == null) {
      _formIssues.add('Position yourself so your upper body is fully visible');
      return false;
    }

    // Calculate arm angles (shoulder to elbow to wrist)
    double leftArmAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightArmAngle = _calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    double avgArmAngle = (leftArmAngle + rightArmAngle) / 2;

    // Calculate shoulder elevation (how high the arms are raised)
    double leftShoulderElevation = _calculateShoulderElevation(
      leftShoulder,
      leftElbow,
    );
    double rightShoulderElevation = _calculateShoulderElevation(
      rightShoulder,
      rightElbow,
    );
    double avgShoulderElevation =
        (leftShoulderElevation + rightShoulderElevation) / 2;

    // Update history
    _armAngleHistory.add(avgArmAngle);
    _shoulderElevationHistory.add(avgShoulderElevation);

    if (_armAngleHistory.length > HISTORY_SIZE) {
      _armAngleHistory.removeAt(0);
      _shoulderElevationHistory.removeAt(0);
    }

    // Analyze form quality
    _analyzeForm(
      avgArmAngle,
      avgShoulderElevation,
      leftShoulder,
      rightShoulder,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
      leftHip,
      rightHip,
      nose,
    );

    // Detect shoulder press phases
    return _detectPhaseTransition(avgArmAngle, avgShoulderElevation);
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

  double _calculateShoulderElevation(
    PoseLandmark shoulder,
    PoseLandmark elbow,
  ) {
    // Calculate angle from horizontal (0 degrees = arm pointing right)
    double deltaX = elbow.x - shoulder.x;
    double deltaY = elbow.y - shoulder.y;
    double angle =
        atan2(-deltaY, deltaX) *
        180 /
        pi; // Negative Y because screen coordinates

    // Normalize to 0-180 degrees (0 = horizontal, 90 = straight up)
    if (angle < 0) angle += 360;
    if (angle > 180) angle = 360 - angle;

    return angle;
  }

  void _analyzeForm(
    double armAngle,
    double shoulderElevation,
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftElbow,
    PoseLandmark rightElbow,
    PoseLandmark leftWrist,
    PoseLandmark rightWrist,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
    PoseLandmark nose,
  ) {
    double quality = 1.0;

    // Check if arms are elevated enough (not pressing from too low)
    if (shoulderElevation < MIN_ELEVATION_ANGLE &&
        _currentPhase == ShoulderPressPhase.bottom) {
      _formIssues.add('Start with your arms higher - elbows at shoulder level');
      quality -= 0.2;
    }

    // Check arm symmetry - both arms should move similarly
    double leftArmAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
    double rightArmAngle = _calculateAngle(
      rightShoulder,
      rightElbow,
      rightWrist,
    );
    double armAngleDifference = (leftArmAngle - rightArmAngle).abs();

    if (armAngleDifference > 20) {
      _formIssues.add('Keep both arms moving symmetrically');
      quality -= 0.15;
    }

    // Check wrist alignment - wrists should be above elbows when pressing
    if (_currentPhase == ShoulderPressPhase.top) {
      bool leftWristAboveElbow = leftWrist.y < leftElbow.y;
      bool rightWristAboveElbow = rightWrist.y < rightElbow.y;

      if (!leftWristAboveElbow || !rightWristAboveElbow) {
        _formIssues.add(
          'Press weights directly overhead - keep wrists above elbows',
        );
        quality -= 0.2;
      }
    }

    // Check posture - avoid leaning forward
    double avgShoulderX = (leftShoulder.x + rightShoulder.x) / 2;
    double avgHipX = (leftHip.x + rightHip.x) / 2;
    double avgShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    double avgHipY = (leftHip.y + rightHip.y) / 2;

    double torsoHeight = (avgHipY - avgShoulderY).abs();
    double forwardLean = (avgShoulderX - avgHipX).abs() / torsoHeight;

    if (forwardLean > MAX_FORWARD_LEAN) {
      _formIssues.add('Keep your torso upright - don\'t lean forward');
      quality -= 0.15;
    }

    // Check range of motion - full extension at top
    if (_currentPhase == ShoulderPressPhase.top &&
        armAngle < TOP_ARM_ANGLE - ANGLE_THRESHOLD) {
      _formIssues.add('Fully extend your arms overhead');
      quality -= 0.1;
    }

    // Check control - movement shouldn't be too erratic
    if (_armAngleHistory.length >= 3) {
      double angleVariation = _calculateVariation(_armAngleHistory);
      if (angleVariation > 20) {
        _formIssues.add('Move more slowly and controlled');
        quality -= 0.1;
      }
    }

    // Check shoulder width - hands should be roughly shoulder-width apart
    double handDistance = sqrt(
      pow(leftWrist.x - rightWrist.x, 2) + pow(leftWrist.y - rightWrist.y, 2),
    );
    double shoulderDistance = sqrt(
      pow(leftShoulder.x - rightShoulder.x, 2) +
          pow(leftShoulder.y - rightShoulder.y, 2),
    );

    double handWidthRatio = handDistance / shoulderDistance;
    if (handWidthRatio < 0.8 || handWidthRatio > 1.5) {
      _formIssues.add(
        'Adjust grip width - hands should be about shoulder-width apart',
      );
      quality -= 0.1;
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

  bool _detectPhaseTransition(double armAngle, double shoulderElevation) {
    if (_framesSinceLastRep < MIN_REP_TIME) return false;

    switch (_currentPhase) {
      case ShoulderPressPhase.bottom:
        // Look for transition to top phase (pressing up)
        if (armAngle > TOP_ARM_ANGLE - ANGLE_THRESHOLD &&
            shoulderElevation > MIN_ELEVATION_ANGLE) {
          _currentPhase = ShoulderPressPhase.top;
        }
        break;

      case ShoulderPressPhase.top:
        // Look for transition back to bottom (complete rep)
        if (armAngle < BOTTOM_ARM_ANGLE + ANGLE_THRESHOLD) {
          _currentPhase = ShoulderPressPhase.bottom;
          _repCount++;
          _framesSinceLastRep = 0;
          return true; // Rep completed
        }
        break;

      case ShoulderPressPhase.transition:
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
