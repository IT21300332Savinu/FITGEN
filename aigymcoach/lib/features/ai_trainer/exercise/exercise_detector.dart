// lib/features/ai_trainer/exercise/exercise_detector.dart
import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum ExerciseState {
  ready,      // Starting position - arm extended
  descending, // Moving down from curl
  ascending,  // Curling up
  hold        // At top of curl
}

enum FormQuality {
  excellent, // Green
  good,      // Light green
  warning,   // Yellow
  poor       // Red
}

class ExerciseMetrics {
  final int repCount;
  final double currentAngle;
  final FormQuality formQuality;
  final String feedback;
  final ExerciseState state;
  final double formScore; // 0-100
  
  ExerciseMetrics({
    required this.repCount,
    required this.currentAngle,
    required this.formQuality,
    required this.feedback,
    required this.state,
    required this.formScore,
  });
}

class BicepCurlDetector {
  // State tracking
  ExerciseState _currentState = ExerciseState.ready;
  int _repCount = 0;
  double _lastAngle = 0;
  List<double> _angleHistory = [];
  List<double> _elbowPositionHistory = [];
  DateTime _lastStateChange = DateTime.now();
  
  // Configuration
  static const double EXTENDED_ANGLE = 140.0;  // Arm fully extended
  static const double CURLED_ANGLE = 60.0;     // Arm fully curled
  static const double ANGLE_THRESHOLD = 10.0;  // Hysteresis for state changes
  static const int HISTORY_SIZE = 10;          // Frames to keep for smoothing
  static const double MIN_REP_TIME = 1.0;      // Minimum seconds per rep
  static const double MAX_ELBOW_MOVEMENT = 0.1; // Max elbow movement for good form

  ExerciseMetrics analyzeFrame(Pose pose) {
    // Get required landmarks
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    // Determine which arm to track (use the one with better visibility/confidence)
    bool useLeftArm = _shouldUseLeftArm(
      leftShoulder, leftElbow, leftWrist,
      rightShoulder, rightElbow, rightWrist
    );

    final shoulder = useLeftArm ? leftShoulder! : rightShoulder!;
    final elbow = useLeftArm ? leftElbow! : rightElbow!;
    final wrist = useLeftArm ? leftWrist! : rightWrist!;

    // Calculate elbow angle
    double angle = _calculateElbowAngle(shoulder, elbow, wrist);
    
    // Update history
    _updateHistory(angle, elbow);
    
    // Analyze movement and update state
    ExerciseState newState = _analyzeMovement(angle);
    
    // Calculate form quality
    FormQuality formQuality = _calculateFormQuality(angle, elbow);
    
    // Generate feedback
    String feedback = _generateFeedback(formQuality, newState, angle);
    
    // Calculate form score
    double formScore = _calculateFormScore(formQuality);

    return ExerciseMetrics(
      repCount: _repCount,
      currentAngle: angle,
      formQuality: formQuality,
      feedback: feedback,
      state: newState,
      formScore: formScore,
    );
  }

  bool _shouldUseLeftArm(
    PoseLandmark? leftShoulder, PoseLandmark? leftElbow, PoseLandmark? leftWrist,
    PoseLandmark? rightShoulder, PoseLandmark? rightElbow, PoseLandmark? rightWrist
  ) {
    // Check if all landmarks are available for both arms
    bool leftArmComplete = leftShoulder != null && leftElbow != null && leftWrist != null;
    bool rightArmComplete = rightShoulder != null && rightElbow != null && rightWrist != null;
    
    if (!leftArmComplete && !rightArmComplete) return true; // Default to left
    if (!rightArmComplete) return true;
    if (!leftArmComplete) return false;
    
    // Use arm with higher average confidence
    double leftConfidence = (leftShoulder!.likelihood + leftElbow!.likelihood + leftWrist!.likelihood) / 3;
    double rightConfidence = (rightShoulder!.likelihood + rightElbow!.likelihood + rightWrist!.likelihood) / 3;
    
    return leftConfidence >= rightConfidence;
  }

  double _calculateElbowAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
    // Vector from elbow to shoulder
    double shoulderX = shoulder.x - elbow.x;
    double shoulderY = shoulder.y - elbow.y;
    
    // Vector from elbow to wrist
    double wristX = wrist.x - elbow.x;
    double wristY = wrist.y - elbow.y;
    
    // Calculate angle using dot product
    double dotProduct = shoulderX * wristX + shoulderY * wristY;
    double shoulderLength = math.sqrt(shoulderX * shoulderX + shoulderY * shoulderY);
    double wristLength = math.sqrt(wristX * wristX + wristY * wristY);
    
    if (shoulderLength == 0 || wristLength == 0) return 0;
    
    double cosAngle = dotProduct / (shoulderLength * wristLength);
    cosAngle = cosAngle.clamp(-1.0, 1.0); // Prevent domain errors
    
    double angleRadians = math.acos(cosAngle);
    double angleDegrees = angleRadians * 180 / math.pi;
    
    return angleDegrees;
  }

  void _updateHistory(double angle, PoseLandmark elbow) {
    _angleHistory.add(angle);
    _elbowPositionHistory.add(elbow.y); // Track vertical elbow movement
    
    if (_angleHistory.length > HISTORY_SIZE) {
      _angleHistory.removeAt(0);
      _elbowPositionHistory.removeAt(0);
    }
  }

  ExerciseState _analyzeMovement(double currentAngle) {
    double smoothedAngle = _getSmoothedAngle();
    DateTime now = DateTime.now();
    double timeSinceLastChange = now.difference(_lastStateChange).inMilliseconds / 1000.0;
    
    ExerciseState newState = _currentState;
    
    switch (_currentState) {
      case ExerciseState.ready:
        // Looking for start of curl (angle decreasing from extended position)
        if (smoothedAngle < EXTENDED_ANGLE - ANGLE_THRESHOLD) {
          newState = ExerciseState.descending;
        }
        break;
        
      case ExerciseState.descending:
        // Check if we've reached the bottom of the curl
        if (smoothedAngle < CURLED_ANGLE + ANGLE_THRESHOLD) {
          newState = ExerciseState.hold;
        }
        // Or if angle starts increasing significantly (incomplete rep)
        else if (_isAngleIncreasing() && timeSinceLastChange > 0.5) {
          newState = ExerciseState.ascending;
        }
        break;
        
      case ExerciseState.hold:
        // Short hold at bottom, then start ascending
        if (timeSinceLastChange > 0.2 || _isAngleIncreasing()) {
          newState = ExerciseState.ascending;
        }
        break;
        
      case ExerciseState.ascending:
        // Check if we've returned to extended position (completed rep)
        if (smoothedAngle > EXTENDED_ANGLE - ANGLE_THRESHOLD && timeSinceLastChange > MIN_REP_TIME) {
          newState = ExerciseState.ready;
          _repCount++; // Increment rep count
        }
        break;
    }
    
    if (newState != _currentState) {
      _currentState = newState;
      _lastStateChange = now;
    }
    
    return newState;
  }

  FormQuality _calculateFormQuality(double angle, PoseLandmark elbow) {
    double formScore = 100.0;
    
    // Check angle range
    if (angle > EXTENDED_ANGLE + 20 || angle < CURLED_ANGLE - 20) {
      formScore -= 30; // Poor range of motion
    }
    
    // Check elbow stability
    if (_elbowPositionHistory.length >= 3) {
      double elbowMovement = _getElbowMovementVariation();
      if (elbowMovement > MAX_ELBOW_MOVEMENT) {
        formScore -= 25; // Elbow swinging too much
      }
    }
    
    // Check movement smoothness
    if (_angleHistory.length >= 3) {
      double smoothness = _getMovementSmoothness();
      if (smoothness > 20) { // High variation indicates jerky movement
        formScore -= 20;
      }
    }
    
    // Check speed (avoid too fast reps)
    DateTime now = DateTime.now();
    double timeSinceLastChange = now.difference(_lastStateChange).inMilliseconds / 1000.0;
    if (_currentState != ExerciseState.ready && timeSinceLastChange < 0.3) {
      formScore -= 15; // Too fast
    }
    
    if (formScore >= 90) return FormQuality.excellent;
    if (formScore >= 75) return FormQuality.good;
    if (formScore >= 60) return FormQuality.warning;
    return FormQuality.poor;
  }

  double _getSmoothedAngle() {
    if (_angleHistory.isEmpty) return 0;
    if (_angleHistory.length < 3) return _angleHistory.last;
    
    // Simple moving average of last 3 readings
    int start = math.max(0, _angleHistory.length - 3);
    double sum = 0;
    for (int i = start; i < _angleHistory.length; i++) {
      sum += _angleHistory[i];
    }
    return sum / (math.min(3, _angleHistory.length));
  }

  bool _isAngleIncreasing() {
    if (_angleHistory.length < 3) return false;
    
    double recent = _angleHistory.last;
    double previous = _angleHistory[_angleHistory.length - 2];
    
    return recent > previous + 5; // 5 degree threshold for noise
  }

  double _getElbowMovementVariation() {
    if (_elbowPositionHistory.length < 3) return 0;
    
    double sum = 0;
    double mean = _elbowPositionHistory.reduce((a, b) => a + b) / _elbowPositionHistory.length;
    
    for (double pos in _elbowPositionHistory) {
      sum += (pos - mean) * (pos - mean);
    }
    
    return math.sqrt(sum / _elbowPositionHistory.length);
  }

  double _getMovementSmoothness() {
    if (_angleHistory.length < 3) return 0;
    
    double totalVariation = 0;
    for (int i = 1; i < _angleHistory.length; i++) {
      totalVariation += (_angleHistory[i] - _angleHistory[i-1]).abs();
    }
    
    return totalVariation / (_angleHistory.length - 1);
  }

  String _generateFeedback(FormQuality quality, ExerciseState state, double angle) {
    switch (quality) {
      case FormQuality.excellent:
        return "Perfect form! Keep it up!";
      case FormQuality.good:
        return "Good form. ${_getStateInstructions(state)}";
      case FormQuality.warning:
        return "Watch your form. ${_getFormCorrections(angle)}";
      case FormQuality.poor:
        return "Poor form! ${_getFormCorrections(angle)}";
    }
  }

  String _getStateInstructions(ExerciseState state) {
    switch (state) {
      case ExerciseState.ready:
        return "Ready for next rep";
      case ExerciseState.descending:
        return "Keep descending slowly";
      case ExerciseState.hold:
        return "Hold the contraction";
      case ExerciseState.ascending:
        return "Control the movement up";
    }
  }

  String _getFormCorrections(double angle) {
    List<String> corrections = [];
    
    if (angle > EXTENDED_ANGLE + 20) {
      corrections.add("Extend arm less");
    }
    if (angle < CURLED_ANGLE - 20) {
      corrections.add("Don't curl too far");
    }
    
    if (_elbowPositionHistory.length >= 3) {
      double movement = _getElbowMovementVariation();
      if (movement > MAX_ELBOW_MOVEMENT) {
        corrections.add("Keep elbow stable");
      }
    }
    
    if (corrections.isEmpty) {
      corrections.add("Slow down your movement");
    }
    
    return corrections.join(", ");
  }

  double _calculateFormScore(FormQuality quality) {
    switch (quality) {
      case FormQuality.excellent:
        return 95.0;
      case FormQuality.good:
        return 80.0;
      case FormQuality.warning:
        return 65.0;
      case FormQuality.poor:
        return 40.0;
    }
  }

  void reset() {
    _currentState = ExerciseState.ready;
    _repCount = 0;
    _angleHistory.clear();
    _elbowPositionHistory.clear();
    _lastStateChange = DateTime.now();
  }
}