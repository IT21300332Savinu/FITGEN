import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_models.dart';
import 'exercise_detector.dart';
import 'pushup_detector.dart' as pushup;
import 'squat_detector.dart' as squat;
import 'arm_circling_detector.dart' as arm;
import 'shoulder_press_detector.dart' as shoulder;

class UnifiedExerciseDetector {
  ExerciseType? _currentExerciseType;

  // Detectors
  BicepCurlDetector? _bicepCurlDetector;
  pushup.PushupDetector? _pushupDetector;
  squat.SquatDetector? _squatDetector;
  arm.ArmCirclingDetector? _armCirclingDetector;
  shoulder.ShoulderPressDetector? _shoulderPressDetector;

  // Current exercise metrics (for unified interface)
  ExerciseMetrics? _currentMetrics;

  ExerciseType? get currentExerciseType => _currentExerciseType;

  void setExerciseType(ExerciseType exerciseType) {
    if (_currentExerciseType == exerciseType) return;

    print(
      '🔄 UnifiedExerciseDetector: Switching to exercise type: $exerciseType',
    );
    _resetAllDetectors();
    _currentExerciseType = exerciseType;
    _initializeDetector(exerciseType);
  }

  void _initializeDetector(ExerciseType exerciseType) {
    print(
      '🔧 UnifiedExerciseDetector: Initializing detector for $exerciseType',
    );
    switch (exerciseType) {
      case ExerciseType.bicepCurl:
        _bicepCurlDetector = BicepCurlDetector();
        print('✅ BicepCurlDetector initialized');
        break;
      case ExerciseType.pushup:
        _pushupDetector = pushup.PushupDetector();
        print('✅ PushupDetector initialized');
        break;
      case ExerciseType.squat:
        _squatDetector = squat.SquatDetector();
        print('✅ SquatDetector initialized');
        break;
      case ExerciseType.armCircling:
        _armCirclingDetector = arm.ArmCirclingDetector();
        print('✅ ArmCirclingDetector initialized');
        break;
      case ExerciseType.shoulderPress:
        _shoulderPressDetector = shoulder.ShoulderPressDetector();
        print('✅ ShoulderPressDetector initialized');
        break;
    }
  }

  void _resetAllDetectors() {
    _bicepCurlDetector = null;
    _pushupDetector = null;
    _squatDetector = null;
    _armCirclingDetector = null;
    _shoulderPressDetector = null;
    _currentMetrics = null;
  }

  // Main detection method that handles both interfaces
  ExerciseMetrics? detectExercise(Pose pose) {
    if (_currentExerciseType == null) {
      print('⚠️ UnifiedExerciseDetector: No exercise type set!');
      return null;
    }

    print('🔍 UnifiedExerciseDetector: Detecting ${_currentExerciseType}...');

    switch (_currentExerciseType!) {
      case ExerciseType.bicepCurl:
        // BicepCurlDetector returns ExerciseMetrics directly
        _currentMetrics = _bicepCurlDetector?.analyzeFrame(pose);
        print('📊 Bicep curl metrics: ${_currentMetrics?.repCount} reps');
        return _currentMetrics;

      case ExerciseType.pushup:
        _pushupDetector?.detectPushup(pose.landmarks.values.toList());
        _currentMetrics = _createMetricsFromPushupDetector();
        print('📊 Pushup metrics: ${_currentMetrics?.repCount} reps');
        return _currentMetrics;

      case ExerciseType.squat:
        _squatDetector?.detectSquat(pose.landmarks.values.toList());
        _currentMetrics = _createMetricsFromSquatDetector();
        print('📊 Squat metrics: ${_currentMetrics?.repCount} reps');
        return _currentMetrics;

      case ExerciseType.armCircling:
        _armCirclingDetector?.detectArmCircling(pose.landmarks.values.toList());
        _currentMetrics = _createMetricsFromArmCirclingDetector();
        print('📊 Arm circling metrics: ${_currentMetrics?.repCount} reps');
        return _currentMetrics;

      case ExerciseType.shoulderPress:
        _shoulderPressDetector?.detectShoulderPress(
          pose.landmarks.values.toList(),
        );
        _currentMetrics = _createMetricsFromShoulderPressDetector();
        print('📊 Shoulder press metrics: ${_currentMetrics?.repCount} reps');
        return _currentMetrics;
    }
  }

  // Helper methods to create ExerciseMetrics from individual detector states
  ExerciseMetrics? _createMetricsFromPushupDetector() {
    if (_pushupDetector == null) return null;

    return ExerciseMetrics(
      repCount: _pushupDetector!.repCount,
      currentAngle: 0.0, // Pushup detector doesn't expose angle
      formQuality: _convertToFormQuality(_pushupDetector!.formQuality),
      feedback: _pushupDetector!.formIssues.join(', '),
      state: _convertPhaseToState(_pushupDetector!.currentPhase.toString()),
      formScore: _pushupDetector!.formQuality,
    );
  }

  ExerciseMetrics? _createMetricsFromSquatDetector() {
    if (_squatDetector == null) return null;

    return ExerciseMetrics(
      repCount: _squatDetector!.repCount,
      currentAngle: 0.0, // Squat detector doesn't expose angle
      formQuality: _convertToFormQuality(_squatDetector!.formQuality),
      feedback: _squatDetector!.formIssues.join(', '),
      state: _convertPhaseToState(_squatDetector!.currentPhase.toString()),
      formScore: _squatDetector!.formQuality,
    );
  }

  ExerciseMetrics? _createMetricsFromArmCirclingDetector() {
    if (_armCirclingDetector == null) return null;

    return ExerciseMetrics(
      repCount: _armCirclingDetector!.repCount,
      currentAngle: 0.0, // Arm circling detector doesn't expose angle
      formQuality: _convertToFormQuality(_armCirclingDetector!.formQuality),
      feedback: _armCirclingDetector!.formIssues.join(', '),
      state: _convertPhaseToState(
        _armCirclingDetector!.currentPhase.toString(),
      ),
      formScore: _armCirclingDetector!.formQuality,
    );
  }

  ExerciseMetrics? _createMetricsFromShoulderPressDetector() {
    if (_shoulderPressDetector == null) return null;

    return ExerciseMetrics(
      repCount: _shoulderPressDetector!.repCount,
      currentAngle: 0.0, // Shoulder press detector doesn't expose angle
      formQuality: _convertToFormQuality(_shoulderPressDetector!.formQuality),
      feedback: _shoulderPressDetector!.formIssues.join(', '),
      state: _convertPhaseToState(
        _shoulderPressDetector!.currentPhase.toString(),
      ),
      formScore: _shoulderPressDetector!.formQuality,
    );
  }

  // Helper to convert double form quality to FormQuality enum
  FormQuality _convertToFormQuality(double quality) {
    if (quality >= 0.85) return FormQuality.excellent;
    if (quality >= 0.70) return FormQuality.good;
    if (quality >= 0.50) return FormQuality.warning;
    return FormQuality.poor;
  }

  // Helper to convert phase string to ExerciseState
  ExerciseState _convertPhaseToState(String phase) {
    final phaseLower = phase.toLowerCase();
    if (phaseLower.contains('ready') || phaseLower.contains('start')) {
      return ExerciseState.ready;
    } else if (phaseLower.contains('up') ||
        phaseLower.contains('extend') ||
        phaseLower.contains('press') ||
        phaseLower.contains('ascending')) {
      return ExerciseState.ascending;
    } else if (phaseLower.contains('down') ||
        phaseLower.contains('lower') ||
        phaseLower.contains('curl') ||
        phaseLower.contains('descending')) {
      return ExerciseState.descending;
    } else if (phaseLower.contains('hold')) {
      return ExerciseState.hold;
    }
    return ExerciseState.ready;
  }

  // Convenience getters for backward compatibility
  int get repCount => _currentMetrics?.repCount ?? 0;
  FormQuality get formQuality =>
      _currentMetrics?.formQuality ?? FormQuality.poor;
  List<String> get formIssues =>
      _currentMetrics?.feedback
          .split(', ')
          .where((s) => s.isNotEmpty)
          .toList() ??
      [];
  String get currentPhase =>
      _currentMetrics?.state.toString().split('.').last ?? 'unknown';

  void reset() {
    _bicepCurlDetector?.reset();
    _pushupDetector?.reset();
    _squatDetector?.reset();
    _armCirclingDetector?.reset();
    _shoulderPressDetector?.reset();
    _currentMetrics = null;
  }

  // Get exercise-specific guidance
  List<String> getExerciseGuidance() {
    if (_currentExerciseType == null) return [];

    final exerciseDefinition = ExerciseDatabase.getExercise(
      _currentExerciseType!,
    );
    if (exerciseDefinition == null) return [];

    switch (_currentExerciseType!) {
      case ExerciseType.bicepCurl:
        return [
          'Keep your upper arms stationary',
          'Focus on squeezing your biceps',
          'Control the weight on the way down',
        ];
      case ExerciseType.pushup:
        return [
          'Keep your body in a straight line',
          'Lower until chest nearly touches ground',
          'Push through your palms',
        ];
      case ExerciseType.squat:
        return [
          'Sit back into your hips',
          'Keep knees tracking over toes',
          'Go as low as comfortable',
        ];
      case ExerciseType.armCircling:
        return [
          'Make large, controlled circles',
          'Keep arms extended',
          'Maintain consistent speed',
        ];
      case ExerciseType.shoulderPress:
        return [
          'Press directly overhead',
          'Keep core tight',
          'Don\'t arch your back excessively',
        ];
    }
  }
}
