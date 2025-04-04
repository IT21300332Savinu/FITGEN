// lib/services/mock_wearable_service.dart
import 'dart:async';
import 'dart:math';
import '../models/health_data.dart';

class MockWearableService {
  // Singleton pattern
  static final MockWearableService _instance = MockWearableService._internal();
  factory MockWearableService() => _instance;
  MockWearableService._internal();

  final Random _random = Random();
  Timer? _healthDataTimer;

  // Stream controllers for real-time data
  final _heartRateController = StreamController<int>.broadcast();
  final _bloodPressureController = StreamController<String>.broadcast();
  final _stepsController = StreamController<int>.broadcast();
  final _sleepHoursController = StreamController<double>.broadcast();

  // Access to streams
  Stream<int> get heartRateStream => _heartRateController.stream;
  Stream<String> get bloodPressureStream => _bloodPressureController.stream;
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<double> get sleepHoursStream => _sleepHoursController.stream;

  // Start generating mock data
  void startMockDataGeneration(String userId) {
    // Cancel any existing timer
    stopMockDataGeneration();

    // Generate data every 3 seconds
    _healthDataTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _generateMockHealthData(userId);
    });
  }

  // Stop data generation
  void stopMockDataGeneration() {
    _healthDataTimer?.cancel();
    _healthDataTimer = null;
  }

  // Generate random health data
  void _generateMockHealthData(String userId) {
    // Generate values within realistic ranges
    final heartRate = 60 + _random.nextInt(40); // 60-100 bpm
    final systolic = 110 + _random.nextInt(40); // 110-150 mmHg
    final diastolic = 70 + _random.nextInt(20); // 70-90 mmHg
    final steps = _random.nextInt(
      100,
    ); // 0-100 steps (simulate small movements)
    final sleepHours = 6 + (_random.nextDouble() * 3); // 6-9 hours

    // Emit values to streams
    _heartRateController.add(heartRate);
    _bloodPressureController.add('$systolic/$diastolic');
    _stepsController.add(steps);
    _sleepHoursController.add(sleepHours);

    // Create a HealthData object for full data saving if needed
    final healthData = HealthData(
      userId: userId,
      heartRate: heartRate,
      bloodPressure: '$systolic/$diastolic',
      steps: steps,
      sleepHours: sleepHours,
    );

    // Print for debugging
    print('Generated mock health data: ${healthData.toMap()}');
  }

  // Get a single snapshot of health data
  HealthData getHealthDataSnapshot(String userId) {
    final heartRate = 60 + _random.nextInt(40);
    final systolic = 110 + _random.nextInt(40);
    final diastolic = 70 + _random.nextInt(20);
    final steps = _random.nextInt(10000);
    final sleepHours = 6 + (_random.nextDouble() * 3);

    return HealthData(
      userId: userId,
      heartRate: heartRate,
      bloodPressure: '$systolic/$diastolic',
      steps: steps,
      sleepHours: sleepHours,
    );
  }

  // Simulate specific health conditions for demonstration
  HealthData simulateCondition(String userId, String condition) {
    switch (condition.toLowerCase()) {
      case 'hypertension':
        return HealthData(
          userId: userId,
          heartRate: 85 + _random.nextInt(20),
          bloodPressure:
              '${150 + _random.nextInt(30)}/${95 + _random.nextInt(10)}',
          steps: 5000 + _random.nextInt(2000),
          sleepHours: 5 + (_random.nextDouble() * 2),
        );
      case 'diabetes':
        return HealthData(
          userId: userId,
          heartRate: 75 + _random.nextInt(15),
          bloodPressure:
              '${130 + _random.nextInt(20)}/${80 + _random.nextInt(10)}',
          steps: 4000 + _random.nextInt(3000),
          sleepHours: 6 + (_random.nextDouble() * 2),
        );
      case 'fatigue':
        return HealthData(
          userId: userId,
          heartRate: 65 + _random.nextInt(15),
          bloodPressure:
              '${115 + _random.nextInt(15)}/${75 + _random.nextInt(10)}',
          steps: 2000 + _random.nextInt(1000),
          sleepHours: 4 + (_random.nextDouble() * 2),
        );
      default:
        return getHealthDataSnapshot(userId);
    }
  }

  // Clean up resources
  void dispose() {
    stopMockDataGeneration();
    _heartRateController.close();
    _bloodPressureController.close();
    _stepsController.close();
    _sleepHoursController.close();
  }
}
