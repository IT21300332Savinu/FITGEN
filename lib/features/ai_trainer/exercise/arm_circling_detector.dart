import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ArmPosition {
  final double x;
  final double y;
  
  ArmPosition(this.x, this.y);
  
  double get distance => sqrt(x * x + y * y);
}

enum ArmCirclingPhase { forward, backward, mixed }
enum CircleDirection { clockwise, counterclockwise }

class ArmCirclingDetector {
  // Thresholds for arm circling detection
  static const double MIN_CIRCLE_RADIUS = 0.15;     // Minimum relative radius
  static const double MAX_CIRCLE_RADIUS = 0.8;      // Maximum relative radius
  static const double MIN_ANGULAR_VELOCITY = 0.5;   // Rad/frame minimum speed
  static const double MAX_ANGULAR_VELOCITY = 2.0;   // Rad/frame maximum speed
  static const int POSITION_HISTORY_SIZE = 30;      // Track 30 positions for circle
  static const int MIN_CIRCLE_COMPLETION = 25;      // Minimum points for full circle
  static const double ANGLE_THRESHOLD = pi / 6;     // 30 degrees threshold

  // State tracking
  ArmCirclingPhase _currentPhase = ArmCirclingPhase.forward;
  int _repCount = 0;
  final List<ArmPosition> _leftArmPositions = [];
  final List<ArmPosition> _rightArmPositions = [];
  final List<double> _leftArmAngles = [];
  final List<double> _rightArmAngles = [];
  
  // Circle tracking
  double _lastLeftAngle = 0;
  double _lastRightAngle = 0;
  int _leftCircleProgress = 0;
  int _rightCircleProgress = 0;
  CircleDirection _leftDirection = CircleDirection.clockwise;
  CircleDirection _rightDirection = CircleDirection.clockwise;
  
  // Form quality tracking
  double _formQuality = 0.75;
  final List<String> _formIssues = [];

  int get repCount => _repCount;
  ArmCirclingPhase get currentPhase => _currentPhase;
  double get formQuality => _formQuality;
  List<String> get formIssues => List.from(_formIssues);

  void reset() {
    _currentPhase = ArmCirclingPhase.forward;
    _repCount = 0;
    _leftArmPositions.clear();
    _rightArmPositions.clear();
    _leftArmAngles.clear();
    _rightArmAngles.clear();
    _lastLeftAngle = 0;
    _lastRightAngle = 0;
    _leftCircleProgress = 0;
    _rightCircleProgress = 0;
    _formQuality = 0.75;
    _formIssues.clear();
  }

  bool detectArmCircling(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return false;

    _formIssues.clear();

    // Get required landmarks
    final leftShoulder = _getLandmark(landmarks, PoseLandmarkType.leftShoulder);
    final rightShoulder = _getLandmark(landmarks, PoseLandmarkType.rightShoulder);
    final leftElbow = _getLandmark(landmarks, PoseLandmarkType.leftElbow);
    final rightElbow = _getLandmark(landmarks, PoseLandmarkType.rightElbow);
    final leftWrist = _getLandmark(landmarks, PoseLandmarkType.leftWrist);
    final rightWrist = _getLandmark(landmarks, PoseLandmarkType.rightWrist);

    if (leftShoulder == null || rightShoulder == null || 
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null) {
      _formIssues.add('Position yourself so your arms are fully visible');
      return false;
    }

    // Calculate arm positions relative to shoulders
    ArmPosition leftArmPos = ArmPosition(
      leftWrist.x - leftShoulder.x,
      leftWrist.y - leftShoulder.y
    );
    
    ArmPosition rightArmPos = ArmPosition(
      rightWrist.x - rightShoulder.x,
      rightWrist.y - rightShoulder.y
    );

    // Calculate angles from horizontal
    double leftAngle = atan2(leftArmPos.y, leftArmPos.x);
    double rightAngle = atan2(rightArmPos.y, rightArmPos.x);

    // Update position history
    _leftArmPositions.add(leftArmPos);
    _rightArmPositions.add(rightArmPos);
    _leftArmAngles.add(leftAngle);
    _rightArmAngles.add(rightAngle);

    if (_leftArmPositions.length > POSITION_HISTORY_SIZE) {
      _leftArmPositions.removeAt(0);
      _rightArmPositions.removeAt(0);
      _leftArmAngles.removeAt(0);
      _rightArmAngles.removeAt(0);
    }

    // Analyze form quality
    _analyzeForm(leftArmPos, rightArmPos, leftElbow, rightElbow, 
                leftShoulder, rightShoulder);

    // Detect circle completion
    return _detectCircleCompletion(leftAngle, rightAngle);
  }

  PoseLandmark? _getLandmark(List<PoseLandmark> landmarks, PoseLandmarkType type) {
    try {
      return landmarks.firstWhere((landmark) => landmark.type == type);
    } catch (e) {
      return null;
    }
  }

  void _analyzeForm(ArmPosition leftArmPos, ArmPosition rightArmPos,
                   PoseLandmark leftElbow, PoseLandmark rightElbow,
                   PoseLandmark leftShoulder, PoseLandmark rightShoulder) {
    double quality = 1.0;

    // Check arm extension - arms should be relatively straight
    double leftArmLength = leftArmPos.distance;
    double rightArmLength = rightArmPos.distance;
    
    // Calculate elbow angles to check straightness
    double leftElbowX = leftElbow.x - leftShoulder.x;
    double leftElbowY = leftElbow.y - leftShoulder.y;
    double leftElbowDistance = sqrt(leftElbowX * leftElbowX + leftElbowY * leftElbowY);
    
    double rightElbowX = rightElbow.x - rightShoulder.x;
    double rightElbowY = rightElbow.y - rightShoulder.y;
    double rightElbowDistance = sqrt(rightElbowX * rightElbowX + rightElbowY * rightElbowY);

    // Check if elbows are too bent (arm not extended enough)
    double leftExtensionRatio = leftElbowDistance / leftArmLength;
    double rightExtensionRatio = rightElbowDistance / rightArmLength;
    
    if (leftExtensionRatio < 0.6 || rightExtensionRatio < 0.6) {
      _formIssues.add('Keep your arms more extended - don\'t bend elbows too much');
      quality -= 0.2;
    }

    // Check circle size consistency
    if (_leftArmPositions.length > 5) {
      double avgLeftRadius = _leftArmPositions
          .map((pos) => pos.distance)
          .reduce((a, b) => a + b) / _leftArmPositions.length;
      
      double avgRightRadius = _rightArmPositions
          .map((pos) => pos.distance)
          .reduce((a, b) => a + b) / _rightArmPositions.length;

      // Check if circles are too small or inconsistent
      if (avgLeftRadius < MIN_CIRCLE_RADIUS || avgRightRadius < MIN_CIRCLE_RADIUS) {
        _formIssues.add('Make larger circles with your arms');
        quality -= 0.25;
      }

      // Check symmetry between arms
      double radiusDifference = (avgLeftRadius - avgRightRadius).abs();
      if (radiusDifference > 0.3) {
        _formIssues.add('Keep both arms making similar sized circles');
        quality -= 0.15;
      }
    }

    // Check movement speed consistency
    if (_leftArmAngles.length > 3) {
      double leftAngularVelocity = _calculateAngularVelocity(_leftArmAngles);
      double rightAngularVelocity = _calculateAngularVelocity(_rightArmAngles);

      if (leftAngularVelocity < MIN_ANGULAR_VELOCITY || 
          rightAngularVelocity < MIN_ANGULAR_VELOCITY) {
        _formIssues.add('Move your arms faster - maintain consistent speed');
        quality -= 0.15;
      }

      if (leftAngularVelocity > MAX_ANGULAR_VELOCITY || 
          rightAngularVelocity > MAX_ANGULAR_VELOCITY) {
        _formIssues.add('Slow down - control your movement');
        quality -= 0.1;
      }
    }

    // Check synchronization between arms
    if (_leftArmAngles.length > 5 && _rightArmAngles.length > 5) {
      double phaseDifference = (_leftArmAngles.last - _rightArmAngles.last).abs();
      if (phaseDifference > pi / 2) { // More than 90 degrees out of sync
        _formIssues.add('Keep your arms synchronized');
        quality -= 0.1;
      }
    }

    // Update form quality with smoothing
    quality = quality.clamp(0.0, 1.0);
    _formQuality = _formQuality * 0.8 + quality * 0.2;
    _formQuality = _formQuality.clamp(0.0, 1.0);
  }

  double _calculateAngularVelocity(List<double> angles) {
    if (angles.length < 2) return 0;
    
    double totalVelocity = 0;
    int count = 0;
    
    for (int i = 1; i < angles.length; i++) {
      double diff = angles[i] - angles[i-1];
      
      // Handle angle wrap-around
      if (diff > pi) diff -= 2 * pi;
      if (diff < -pi) diff += 2 * pi;
      
      totalVelocity += diff.abs();
      count++;
    }
    
    return count > 0 ? totalVelocity / count : 0;
  }

  bool _detectCircleCompletion(double leftAngle, double rightAngle) {
    bool repCompleted = false;

    // Track circle progress for left arm
    if (_lastLeftAngle != 0) {
      double leftAngleDiff = leftAngle - _lastLeftAngle;
      
      // Handle angle wrap-around
      if (leftAngleDiff > pi) leftAngleDiff -= 2 * pi;
      if (leftAngleDiff < -pi) leftAngleDiff += 2 * pi;

      if (leftAngleDiff.abs() > ANGLE_THRESHOLD) {
        _leftCircleProgress++;
        
        // Determine direction
        _leftDirection = leftAngleDiff > 0 ? 
            CircleDirection.counterclockwise : CircleDirection.clockwise;
      }
    }

    // Track circle progress for right arm
    if (_lastRightAngle != 0) {
      double rightAngleDiff = rightAngle - _lastRightAngle;
      
      // Handle angle wrap-around
      if (rightAngleDiff > pi) rightAngleDiff -= 2 * pi;
      if (rightAngleDiff < -pi) rightAngleDiff += 2 * pi;

      if (rightAngleDiff.abs() > ANGLE_THRESHOLD) {
        _rightCircleProgress++;
        
        // Determine direction
        _rightDirection = rightAngleDiff > 0 ? 
            CircleDirection.counterclockwise : CircleDirection.clockwise;
      }
    }

    // Check if both arms completed a circle
    if (_leftCircleProgress >= MIN_CIRCLE_COMPLETION && 
        _rightCircleProgress >= MIN_CIRCLE_COMPLETION) {
      _repCount++;
      _leftCircleProgress = 0;
      _rightCircleProgress = 0;
      repCompleted = true;

      // Update phase based on direction
      if (_leftDirection == CircleDirection.clockwise && 
          _rightDirection == CircleDirection.clockwise) {
        _currentPhase = ArmCirclingPhase.forward;
      } else if (_leftDirection == CircleDirection.counterclockwise && 
                 _rightDirection == CircleDirection.counterclockwise) {
        _currentPhase = ArmCirclingPhase.backward;
      } else {
        _currentPhase = ArmCirclingPhase.mixed;
      }
    }

    _lastLeftAngle = leftAngle;
    _lastRightAngle = rightAngle;

    return repCompleted;
  }

  FormQuality getFormQualityLevel() {
    if (_formQuality >= 0.85) return FormQuality.excellent;
    if (_formQuality >= 0.70) return FormQuality.good;
    if (_formQuality >= 0.50) return FormQuality.fair;
    return FormQuality.poor;
  }
}

enum FormQuality { excellent, good, fair, poor }