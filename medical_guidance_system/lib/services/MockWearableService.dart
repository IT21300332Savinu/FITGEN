import 'dart:async';
import '../models/health_data.dart';

class MockWearableService {
  final StreamController<int> _heartRateController = StreamController<int>();
  final StreamController<String> _bloodPressureController =
      StreamController<String>();
  final StreamController<int> _stepsController = StreamController<int>();
  final StreamController<double> _sleepHoursController =
      StreamController<double>();

  Stream<int> get heartRateStream => _heartRateController.stream;
  Stream<String> get bloodPressureStream => _bloodPressureController.stream;
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<double> get sleepHoursStream => _sleepHoursController.stream;

  void startMockDataGeneration(String userId) {
    // Simulate mock data generation
    Timer.periodic(Duration(seconds: 1), (timer) {
      _heartRateController.add(60 + timer.tick % 40); // Random heart rate
      _bloodPressureController.add(
        '${120 + timer.tick % 10}/${80 + timer.tick % 5}',
      ); // Random blood pressure
      _stepsController.add(timer.tick * 10); // Incremental steps
      _sleepHoursController.add(
        (timer.tick % 8).toDouble(),
      ); // Random sleep hours
    });
  }

  void stopMockDataGeneration() {
    _heartRateController.close();
    _bloodPressureController.close();
    _stepsController.close();
    _sleepHoursController.close();
  }

  HealthData getHealthDataSnapshot(String userId) {
    return HealthData(
      userId: userId,
      heartRate: 70,
      bloodPressure: '120/80',
      steps: 0,
      sleepHours: 7.0,
    );
  }

  HealthData simulateCondition(String userId, String condition) {
    // Simulate a specific health condition
    if (condition == 'high_heart_rate') {
      return HealthData(
        userId: userId,
        heartRate: 120,
        bloodPressure: '140/90',
        steps: 0,
        sleepHours: 6.0,
      );
    }
    return getHealthDataSnapshot(userId);
  }
}
