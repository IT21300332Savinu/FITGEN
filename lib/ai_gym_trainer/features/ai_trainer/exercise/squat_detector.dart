import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum SquatPhase { standing, squatting, transition }

class SquatDetector {
  // Angle thresholds for squat detection
  static const double STANDING_KNEE_ANGLE = 160.0; // Degrees when standing
  static const double SQUATTING_KNEE_ANGLE = 90.0; // Degrees at bottom of squat
  static const double ANGLE_THRESHOLD = 15.0; // Tolerance for angle detection
  static const double MIN_HIP_ANGLE = 80.0; // Minimum hip flexion for squat
  static const double MAX_KNEE_FORWARD = 0.1; // Max knee forward travel ratio
  static const int HISTORY_SIZE = 5; // Frames to track for stability
  static const int MIN_REP_TIME = 30; // Minimum frames between reps

  // State tracking
  SquatPhase _currentPhase = SquatPhase.standing;
  int _repCount = 0;
  int _framesSinceLastRep = 0;
  final List<double> _kneeAngleHistory = [];
  final List<double> _hipAngleHistory = [];
  final List<double> _ankleDepthHistory = [];

  // Form quality tracking
  double _formQuality = 0.75;
  final List<String> _formIssues = [];

  int get repCount => _repCount;
  SquatPhase get currentPhase => _currentPhase;
  double get formQuality => _formQuality;
  List<String> get formIssues => List.from(_formIssues);

  void reset() {
    _currentPhase = SquatPhase.standing;
    _repCount = 0;
    _framesSinceLastRep = 0;
    _kneeAngleHistory.clear();
    _hipAngleHistory.clear();
    _ankleDepthHistory.clear();
    _formQuality = 0.75;
    _formIssues.clear();
  }

  bool detectSquat(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return false;

    _framesSinceLastRep++;
    _formIssues.clear();

    // Get required landmarks
    final leftHip = _getLandmark(landmarks, PoseLandmarkType.leftHip);
    final rightHip = _getLandmark(landmarks, PoseLandmarkType.rightHip);
    final leftKnee = _getLandmark(landmarks, PoseLandmarkType.leftKnee);
    final rightKnee = _getLandmark(landmarks, PoseLandmarkType.rightKnee);
    final leftAnkle = _getLandmark(landmarks, PoseLandmarkType.leftAnkle);
    final rightAnkle = _getLandmark(landmarks, PoseLandmarkType.rightAnkle);
    final leftShoulder = _getLandmark(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = _getLandmark(
      landmarks,
      PoseLandmarkType.rightShoulder,
    );

    if (leftHip == null ||
        rightHip == null ||
        leftKnee == null ||
        rightKnee == null ||
        leftAnkle == null ||
        rightAnkle == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      _formIssues.add('Position yourself so your legs and torso are visible');
      return false;
    }

    // Calculate angles
    double leftKneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = _calculateAngle(rightHip, rightKnee, rightAnkle);
    double avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    // Calculate hip angles (hip flexion)
    double leftHipAngle = _calculateAngle(leftShoulder, leftHip, leftKnee);
    double rightHipAngle = _calculateAngle(rightShoulder, rightHip, rightKnee);
    double avgHipAngle = (leftHipAngle + rightHipAngle) / 2;

    // Calculate depth (how low the hips go)
    double hipHeight = (leftHip.y + rightHip.y) / 2;
    double kneeHeight = (leftKnee.y + rightKnee.y) / 2;
    double depth = hipHeight - kneeHeight; // Negative when hips below knees

    // Update history
    _kneeAngleHistory.add(avgKneeAngle);
    _hipAngleHistory.add(avgHipAngle);
    _ankleDepthHistory.add(depth);

    if (_kneeAngleHistory.length > HISTORY_SIZE) {
      _kneeAngleHistory.removeAt(0);
      _hipAngleHistory.removeAt(0);
      _ankleDepthHistory.removeAt(0);
    }

    // Analyze form quality
    _analyzeForm(
      avgKneeAngle,
      avgHipAngle,
      depth,
      leftKnee,
      rightKnee,
      leftAnkle,
      rightAnkle,
      leftHip,
      rightHip,
    );

    // Detect squat phases
    return _detectPhaseTransition(avgKneeAngle, avgHipAngle);
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
    double kneeAngle,
    double hipAngle,
    double depth,
    PoseLandmark leftKnee,
    PoseLandmark rightKnee,
    PoseLandmark leftAnkle,
    PoseLandmark rightAnkle,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
  ) {
    double quality = 1.0;

    // Check squat depth - hips should go below knees
    if (depth > 0 && _currentPhase == SquatPhase.squatting) {
      _formIssues.add('Go deeper - hips should go below knee level');
      quality -= 0.25;
    }

    // Check knee tracking - knees shouldn't cave inward
    double kneeWidth = (leftKnee.x - rightKnee.x).abs();
    double ankleWidth = (leftAnkle.x - rightAnkle.x).abs();
    double kneeTrackingRatio = kneeWidth / ankleWidth;

    if (kneeTrackingRatio < 0.8) {
      _formIssues.add(
        'Keep knees tracking over toes - don\'t let them cave in',
      );
      quality -= 0.3;
    }

    // Check if knees go too far forward
    double avgKneeX = (leftKnee.x + rightKnee.x) / 2;
    double avgAnkleX = (leftAnkle.x + rightAnkle.x) / 2;
    double kneeForwardRatio = (avgKneeX - avgAnkleX).abs() / ankleWidth;

    if (kneeForwardRatio > MAX_KNEE_FORWARD) {
      _formIssues.add('Don\'t let knees go too far forward - sit back more');
      quality -= 0.2;
    }

    // Check hip flexion - need sufficient hip bend
    if (hipAngle > 130 && _currentPhase == SquatPhase.squatting) {
      _formIssues.add('Bend more at the hips - push your hips back');
      quality -= 0.2;
    }

    // Check for controlled movement
    if (_kneeAngleHistory.length >= 3) {
      double angleVariation = _calculateVariation(_kneeAngleHistory);
      if (angleVariation > 25) {
        _formIssues.add('Move more slowly and controlled');
        quality -= 0.15;
      }
    }

    // Check symmetry between legs
    double leftKneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
    double rightKneeAngle = _calculateAngle(rightHip, rightKnee, rightAnkle);

    if ((leftKneeAngle - rightKneeAngle).abs() > 15) {
      _formIssues.add('Keep both legs moving symmetrically');
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

  bool _detectPhaseTransition(double kneeAngle, double hipAngle) {
    if (_framesSinceLastRep < MIN_REP_TIME) return false;

    switch (_currentPhase) {
      case SquatPhase.standing:
        // Look for transition to squatting phase
        if (kneeAngle < STANDING_KNEE_ANGLE - ANGLE_THRESHOLD &&
            hipAngle < 140) {
          _currentPhase = SquatPhase.squatting;
        }
        break;

      case SquatPhase.squatting:
        // Look for transition back to standing (complete rep)
        if (kneeAngle > STANDING_KNEE_ANGLE - ANGLE_THRESHOLD &&
            hipAngle > 160) {
          _currentPhase = SquatPhase.standing;
          _repCount++;
          _framesSinceLastRep = 0;
          return true; // Rep completed
        }
        break;

      case SquatPhase.transition:
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
