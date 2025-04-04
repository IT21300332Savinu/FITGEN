import 'package:flutter/material.dart';
import 'package:medical_guidance_system/models/mock_wearable_service.dart';
import '../models/health_data.dart';

class MockWearableProvider with ChangeNotifier {
  final MockWearableService _mockWearableService = MockWearableService();
  String? _userId;
  HealthData? _latestHealthData;

  // Getters for latest data
  HealthData? get latestHealthData => _latestHealthData;
  int get heartRate => _latestHealthData?.heartRate ?? 0;
  String get bloodPressure => _latestHealthData?.bloodPressure ?? '0/0';
  int get steps => _latestHealthData?.steps ?? 0;
  double get sleepHours => _latestHealthData?.sleepHours ?? 0.0;

  // Getters for streams
  Stream<int> get heartRateStream => _mockWearableService.heartRateStream;
  Stream<String> get bloodPressureStream =>
      _mockWearableService.bloodPressureStream;
  Stream<int> get stepsStream => _mockWearableService.stepsStream;
  Stream<double> get sleepHoursStream => _mockWearableService.sleepHoursStream;

  // Start monitoring for a specific user
  void startMonitoring(String userId) {
    _userId = userId;
    _mockWearableService.startMockDataGeneration(userId);

    // Initialize with a snapshot
    _latestHealthData = _mockWearableService.getHealthDataSnapshot(userId);
    notifyListeners();

    // Listen to the streams to update latest data
    _mockWearableService.heartRateStream.listen((heartRate) {
      if (_latestHealthData != null) {
        _latestHealthData = HealthData(
          userId: _userId!,
          heartRate: heartRate,
          bloodPressure: _latestHealthData!.bloodPressure,
          steps: _latestHealthData!.steps,
          sleepHours: _latestHealthData!.sleepHours,
        );
        notifyListeners();
      }
    });

    _mockWearableService.bloodPressureStream.listen((bloodPressure) {
      if (_latestHealthData != null) {
        _latestHealthData = HealthData(
          userId: _userId!,
          heartRate: _latestHealthData!.heartRate,
          bloodPressure: bloodPressure,
          steps: _latestHealthData!.steps,
          sleepHours: _latestHealthData!.sleepHours,
        );
        notifyListeners();
      }
    });

    _mockWearableService.stepsStream.listen((steps) {
      if (_latestHealthData != null) {
        _latestHealthData = HealthData(
          userId: _userId!,
          heartRate: _latestHealthData!.heartRate,
          bloodPressure: _latestHealthData!.bloodPressure,
          steps: steps,
          sleepHours: _latestHealthData!.sleepHours,
        );
        notifyListeners();
      }
    });

    _mockWearableService.sleepHoursStream.listen((sleepHours) {
      if (_latestHealthData != null) {
        _latestHealthData = HealthData(
          userId: _userId!,
          heartRate: _latestHealthData!.heartRate,
          bloodPressure: _latestHealthData!.bloodPressure,
          steps: _latestHealthData!.steps,
          sleepHours: sleepHours,
        );
        notifyListeners();
      }
    });
  }

  // Simulate a specific health condition
  void simulateHealthCondition(String condition) {
    if (_userId != null) {
      _latestHealthData = _mockWearableService.simulateCondition(
        _userId!,
        condition,
      );
      notifyListeners();
    }
  }

  // Stop monitoring
  void stopMonitoring() {
    _mockWearableService.stopMockDataGeneration();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
