// lib/features/ai_trainer/services/voice_coach_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import '../exercise/exercise_detector.dart';

class VoiceCoachService {
  static final VoiceCoachService _instance = VoiceCoachService._internal();
  factory VoiceCoachService() => _instance;
  VoiceCoachService._internal();

  late FlutterTts _flutterTts;
  bool _isEnabled = true;
  bool _isInitialized = false;
  
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
    
    // Welcome message
    if (_isEnabled) {
      await _speak("Welcome to Bicep Curl Trainer. Position yourself in front of the camera to begin.");
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
      message = "Amazing! $repCount reps completed. Keep up the excellent work!";
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

  Future<void> _announceStateChange(ExerciseState state, FormQuality formQuality) async {
    String message;
    
    switch (state) {
      case ExerciseState.ready:
        if (!_hasGivenReadyInstruction) {
          message = "Ready position. Keep your elbows at your sides and begin curling slowly.";
          _hasGivenReadyInstruction = true;
        } else {
          return; // Don't repeat ready instructions
        }
        break;
      case ExerciseState.descending:
        if (formQuality == FormQuality.poor) {
          message = "Slow down. Control the movement.";
        } else {
          return; // Don't announce every descending phase
        }
        break;
      case ExerciseState.hold:
        message = "Hold the contraction. Feel the muscle working.";
        break;
      case ExerciseState.ascending:
        if (formQuality == FormQuality.poor) {
          message = "Keep your elbows stable. Slow and controlled.";
        } else {
          return; // Don't announce every ascending phase
        }
        break;
    }
    
    await _speak(message);
  }

  Future<void> _announceFormFeedback(FormQuality formQuality, double angle) async {
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
          message = "Watch your range. Don't extend too far.";
        } else if (angle < 30) {
          message = "Don't curl too high. Control the movement.";
        } else {
          message = "Keep your elbows stable and move slowly.";
        }
        break;
      case FormQuality.poor:
        if (angle > 170) {
          message = "Stop. Your arms are too extended. Keep elbows slightly bent.";
        } else if (angle < 30) {
          message = "Stop. Don't curl too far. Focus on controlled movement.";
        } else {
          message = "Poor form detected. Keep elbows at your sides and move slowly.";
        }
        break;
    }
    
    await _speak(message);
  }

  Future<void> announceWorkoutStart() async {
    await _speak("Workout starting. Stand tall, hold your weights, and keep your core engaged. Let's begin!");
  }

  Future<void> announceWorkoutComplete(int totalReps, double averageForm) async {
    String message = "Workout complete! You did $totalReps reps with ${averageForm.toInt()}% average form. ";
    
    if (averageForm >= 90) {
      message += "Outstanding technique!";
    } else if (averageForm >= 75) {
      message += "Great job! Keep practicing for even better form.";
    } else if (averageForm >= 60) {
      message += "Good effort! Focus on slower, more controlled movements next time.";
    } else {
      message += "Keep practicing! Remember to keep your elbows stable and move slowly.";
    }
    
    await _speak(message);
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
    await _speak("Switched to $camera camera. Position yourself for the best view.");
  }

  Future<void> announceGeneralInstruction() async {
    await _speak(
      "Remember: Keep your elbows at your sides, move slowly and controlled, "
      "and focus on squeezing your biceps at the top of each rep."
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
    await _speak("Voice coaching is working perfectly. You're ready to start your workout!");
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _flutterTts.stop();
    }
  }
}