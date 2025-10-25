// lib/features/ai_trainer/services/voice_coach_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import '../exercise/exercise_detector.dart';
import '../models/exercise_models.dart';

class VoiceCoachService {
  static final VoiceCoachService _instance = VoiceCoachService._internal();
  factory VoiceCoachService() => _instance;
  VoiceCoachService._internal();

  late FlutterTts _flutterTts;
  bool _isEnabled = true;
  bool _isInitialized = false;
  ExerciseType _currentExercise = ExerciseType.bicepCurl;

  // Voice coaching state
  ExerciseState? _lastState;
  int _lastRepCount = 0;
  FormQuality? _lastFormQuality;
  DateTime _lastAnnouncementTime = DateTime.now();
  bool _hasGivenReadyInstruction = false;

  // Voice settings
  double _volume = 0.8;
  double _rate = 0.5; // Slower speech for better understanding
  double _pitch = 1.0;

  // Set the current exercise type for appropriate coaching
  void setExerciseType(ExerciseType exerciseType) {
    _currentExercise = exerciseType;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // Configure TTS settings
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setPitch(_pitch);

    // Set language (you can change this)
    await _flutterTts.setLanguage("en-US");

    _isInitialized = true;

    // Exercise-specific welcome message
    if (_isEnabled) {
      String welcomeMessage = _getWelcomeMessage();
      await _speak(welcomeMessage);
    }
  }

  String _getWelcomeMessage() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Welcome to Bicep Curl Trainer. Position yourself in front of the camera to begin.";
      case ExerciseType.squat:
        return "Welcome to Squat Trainer. Stand with feet shoulder-width apart and position yourself in front of the camera.";
      case ExerciseType.pushup:
        return "Welcome to Push-up Trainer. Get into plank position in front of the camera to begin.";
      case ExerciseType.shoulderPress:
        return "Welcome to Shoulder Press Trainer. Hold weights at shoulder level and position yourself in front of the camera.";
      case ExerciseType.armCircling:
        return "Welcome to Arm Circling Trainer. Extend your arms and position yourself in front of the camera.";
    }
  }

  Future<void> _speak(String text) async {
    if (!_isEnabled || !_isInitialized) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  Future<void> analyzeExercise(ExerciseMetrics metrics) async {
    if (!_isEnabled || !_isInitialized) return;

    DateTime now = DateTime.now();
    bool shouldAnnounce = now.difference(_lastAnnouncementTime).inSeconds >= 2;

    // Rep count announcements
    if (metrics.repCount > _lastRepCount) {
      await _announceRepCompleted(metrics.repCount);
      _lastRepCount = metrics.repCount;
      _lastAnnouncementTime = now;
      return; // Don't give other feedback immediately after rep announcement
    }

    // State-based coaching
    if (metrics.state != _lastState && shouldAnnounce) {
      await _announceStateChange(metrics.state, metrics.formQuality);
      _lastState = metrics.state;
      _lastAnnouncementTime = now;
    }

    // Form quality coaching (less frequent)
    if (metrics.formQuality != _lastFormQuality &&
        now.difference(_lastAnnouncementTime).inSeconds >= 5) {
      await _announceFormFeedback(metrics.formQuality, metrics.currentAngle);
      _lastFormQuality = metrics.formQuality;
      _lastAnnouncementTime = now;
    }
  }

  Future<void> _announceRepCompleted(int repCount) async {
    String message;

    if (repCount == 1) {
      message = "Great! First rep completed. Keep going!";
    } else if (repCount % 5 == 0) {
      message = "Excellent! $repCount reps done. You're doing great!";
    } else if (repCount % 10 == 0) {
      message =
          "Amazing! $repCount reps completed. Keep up the excellent work!";
    } else {
      List<String> encouragements = [
        "Good rep! $repCount down.",
        "Nice work! Rep $repCount completed.",
        "Keep it up! That's $repCount reps.",
        "Perfect! $repCount reps done.",
      ];
      message = encouragements[repCount % encouragements.length];
    }

    await _speak(message);
  }

  Future<void> _announceStateChange(
    ExerciseState state,
    FormQuality formQuality,
  ) async {
    String message;

    switch (state) {
      case ExerciseState.ready:
        if (!_hasGivenReadyInstruction) {
          message = _getReadyInstruction();
          _hasGivenReadyInstruction = true;
        } else {
          return; // Don't repeat ready instructions
        }
        break;
      case ExerciseState.descending:
        if (formQuality == FormQuality.poor) {
          message = _getDescendingInstruction();
        } else {
          return; // Don't announce every descending phase
        }
        break;
      case ExerciseState.hold:
        message = _getHoldInstruction();
        break;
      case ExerciseState.ascending:
        if (formQuality == FormQuality.poor) {
          message = _getAscendingInstruction();
        } else {
          return; // Don't announce every ascending phase
        }
        break;
    }

    await _speak(message);
  }

  String _getReadyInstruction() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Ready position. Keep your elbows at your sides and begin curling slowly.";
      case ExerciseType.squat:
        return "Ready position. Keep your feet shoulder-width apart and begin squatting down.";
      case ExerciseType.pushup:
        return "Ready position. Keep your body straight and begin lowering down.";
      case ExerciseType.shoulderPress:
        return "Ready position. Keep weights at shoulder level and begin pressing up.";
      case ExerciseType.armCircling:
        return "Ready position. Extend your arms and begin making circles.";
    }
  }

  String _getDescendingInstruction() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Slow down. Control the movement.";
      case ExerciseType.squat:
        return "Control the descent. Don't drop too fast.";
      case ExerciseType.pushup:
        return "Lower slowly. Keep your body straight.";
      case ExerciseType.shoulderPress:
        return "Control the descent. Lower the weights slowly.";
      case ExerciseType.armCircling:
        return "Keep the circles smooth and controlled.";
    }
  }

  String _getHoldInstruction() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Hold the contraction. Feel the muscle working.";
      case ExerciseType.squat:
        return "Hold the bottom position. Feel the burn.";
      case ExerciseType.pushup:
        return "Hold the bottom position. Keep your form tight.";
      case ExerciseType.shoulderPress:
        return "Hold at the top. Feel the shoulder engagement.";
      case ExerciseType.armCircling:
        return "Keep the circles steady and consistent.";
    }
  }

  String _getAscendingInstruction() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Keep your elbows stable. Slow and controlled.";
      case ExerciseType.squat:
        return "Drive through your heels. Keep your back straight.";
      case ExerciseType.pushup:
        return "Push up strong. Keep your core engaged.";
      case ExerciseType.shoulderPress:
        return "Press up smoothly. Keep your core tight.";
      case ExerciseType.armCircling:
        return "Maintain the circular motion. Keep arms extended.";
    }
  }

  Future<void> _announceFormFeedback(
    FormQuality formQuality,
    double angle,
  ) async {
    String message;

    switch (formQuality) {
      case FormQuality.excellent:
        message = "Perfect form! Keep it up!";
        break;
      case FormQuality.good:
        message = "Good technique. Stay focused.";
        break;
      case FormQuality.warning:
        if (angle > 170) {
          message = "Nice work. Watch your range, don't extend too far.";
        } else if (angle < 30) {
          message = "Good effort. Control the movement at the top.";
        } else {
          message = _getWarningMessage();
        }
        break;
      case FormQuality.poor:
        if (angle > 170) {
          message = _getPoorFormHighAngleMessage();
        } else if (angle < 30) {
          message = "Easy does it. Focus on controlled movement.";
        } else {
          message = _getPoorFormMessage();
        }
        break;
    }

    await _speak(message);
  }

  String _getWarningMessage() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Keep going. Focus on keeping your elbows stable.";
      case ExerciseType.squat:
        return "Watch your form. Keep your back straight.";
      case ExerciseType.pushup:
        return "Maintain good form. Keep your body aligned.";
      case ExerciseType.shoulderPress:
        return "Stay controlled. Keep your core engaged.";
      case ExerciseType.armCircling:
        return "Keep the circles consistent. Maintain arm extension.";
    }
  }

  String _getPoorFormHighAngleMessage() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Slow down. Keep elbows slightly bent for safety.";
      case ExerciseType.squat:
        return "Don't go too low. Stop at comfortable depth.";
      case ExerciseType.pushup:
        return "Don't go too low. Maintain control.";
      case ExerciseType.shoulderPress:
        return "Control the range. Don't overextend.";
      case ExerciseType.armCircling:
        return "Smaller circles. Keep arms under control.";
    }
  }

  String _getPoorFormMessage() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Take your time. Keep elbows at your sides and move slowly.";
      case ExerciseType.squat:
        return "Slow down. Focus on proper squat form.";
      case ExerciseType.pushup:
        return "Take your time. Keep your body straight.";
      case ExerciseType.shoulderPress:
        return "Move slowly. Focus on shoulder stability.";
      case ExerciseType.armCircling:
        return "Slow and steady. Maintain smooth circular motion.";
    }
  }

  Future<void> announceWorkoutStart() async {
    String message = _getWorkoutStartMessage();
    await _speak(message);
  }

  String _getWorkoutStartMessage() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Workout starting. Stand tall, hold your weights, and keep your core engaged. Let's begin!";
      case ExerciseType.squat:
        return "Workout starting. Stand with feet shoulder-width apart, keep your back straight. Let's begin!";
      case ExerciseType.pushup:
        return "Workout starting. Get into plank position, keep your core tight. Let's begin!";
      case ExerciseType.shoulderPress:
        return "Workout starting. Hold weights at shoulder level, keep your core engaged. Let's begin!";
      case ExerciseType.armCircling:
        return "Workout starting. Extend your arms out to the sides. Let's begin!";
    }
  }

  Future<void> announceWorkoutComplete(
    int totalReps,
    double averageForm,
  ) async {
    String message =
        "Workout complete! You did $totalReps reps with ${averageForm.toInt()}% average form. ";

    if (averageForm >= 90) {
      message += "Outstanding technique!";
    } else if (averageForm >= 75) {
      message += "Great job! Keep practicing for even better form.";
    } else if (averageForm >= 60) {
      message +=
          "Good effort! Focus on slower, more controlled movements next time.";
    } else {
      message += _getImprovementTips();
    }

    await _speak(message);
  }

  String _getImprovementTips() {
    switch (_currentExercise) {
      case ExerciseType.bicepCurl:
        return "Keep practicing! Remember to keep your elbows stable and move slowly.";
      case ExerciseType.squat:
        return "Keep practicing! Focus on keeping your back straight and controlled descent.";
      case ExerciseType.pushup:
        return "Keep practicing! Remember to keep your body aligned and core engaged.";
      case ExerciseType.shoulderPress:
        return "Keep practicing! Focus on shoulder stability and controlled movements.";
      case ExerciseType.armCircling:
        return "Keep practicing! Remember to maintain smooth, consistent circular motions.";
    }
  }

  Future<void> announceReset() async {
    await _speak("Exercise reset. Ready to start fresh!");
    _lastRepCount = 0;
    _lastState = null;
    _lastFormQuality = null;
    _hasGivenReadyInstruction = false;
  }

  Future<void> announceCameraSwitch(bool isFrontCamera) async {
    String camera = isFrontCamera ? "front" : "back";
    await _speak(
      "Switched to $camera camera. Position yourself for the best view.",
    );
  }

  Future<void> announceGeneralInstruction() async {
    await _speak(
      "Remember: Keep your elbows at your sides, move slowly and controlled, "
      "and focus on squeezing your biceps at the top of each rep.",
    );
  }

  // Settings
  bool get isEnabled => _isEnabled;

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (enabled && !_isInitialized) {
      await initialize();
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_isInitialized) {
      await _flutterTts.setVolume(_volume);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _rate = rate.clamp(0.1, 1.0);
    if (_isInitialized) {
      await _flutterTts.setSpeechRate(_rate);
    }
  }

  Future<void> testVoice() async {
    await _speak(
      "Voice coaching is working perfectly. You're ready to start your workout!",
    );
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }
}
