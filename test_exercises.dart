// Simple test to verify exercise detection
import 'lib/features/ai_trainer/models/exercise_models.dart';

void main() {
  print('🧪 Testing Exercise Type Mapping...\n');

  final exercises = [
    'Bicep Curl',
    'Pushup',
    'Squat',
    'Shoulder Press',
    'Arm Circling',
  ];

  for (String exercise in exercises) {
    ExerciseType type = getExerciseTypeFromName(exercise);
    print('Exercise: "$exercise" -> Type: $type');
  }

  print('\n🧪 Testing with AI suffix...\n');

  final aiExercises = [
    'Bicep Curl (AI)',
    'Pushup (AI)',
    'Squat (AI)',
    'Shoulder Press (AI)',
    'Arm Circling (AI)',
  ];

  for (String exercise in aiExercises) {
    String clean = exercise.replaceAll(' (AI)', '');
    ExerciseType type = getExerciseTypeFromName(clean);
    print('Exercise: "$exercise" -> Clean: "$clean" -> Type: $type');
  }
}

ExerciseType getExerciseTypeFromName(String exerciseName) {
  final name = exerciseName.toLowerCase().trim();

  if (name.contains('bicep') || name.contains('curl')) {
    return ExerciseType.bicepCurl;
  } else if (name.contains('pushup') ||
      name.contains('push-up') ||
      name.contains('push up')) {
    return ExerciseType.pushup;
  } else if (name.contains('squat')) {
    return ExerciseType.squat;
  } else if (name.contains('arm circling') || name.contains('arm circle')) {
    return ExerciseType.armCircling;
  } else if (name.contains('shoulder press') || name.contains('press')) {
    return ExerciseType.shoulderPress;
  } else {
    return ExerciseType.bicepCurl; // Default
  }
}
