import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/firebase_config .dart';

class IoTDataService {
  // Use the IoT Firebase instance specifically for FitgenMedical
  static FirebaseFirestore get _firestore =>
      FirebaseFirestore.instanceFor(app: FirebaseConfig.iotApp);

  static StreamSubscription? _heartRateSubscription;

  // Initialize IoT connection using the specific Firebase app
  static Future<void> initializeIoTConnection() async {
    try {
      print('IoT Firestore connection initialized for FitgenMedical project');

      // Test the connection immediately
      await testConnection();
    } catch (e) {
      print('Error initializing IoT connection: $e');
    }
  }

  // Test connection to the FitgenMedical project
  static Future<bool> testConnection() async {
    try {
      print('Testing Firestore connection to FitgenMedical...');

      // Try to read from the Data collection in FitgenMedical project
      QuerySnapshot snapshot = await _firestore
          .collection('Data')
          .limit(1)
          .get();

      print('✓ Connection test successful to FitgenMedical');
      print('✓ Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        print('✓ Sample data from FitgenMedical: $data');
      }

      return true;
    } catch (e) {
      print('❌ Connection test failed to FitgenMedical: $e');
      return false;
    }
  }

  // Test connection and debug data structure
  static Future<void> debugDataCollection() async {
    try {
      print('=== IoT DEBUG: Testing FitgenMedical connection ===');
      QuerySnapshot snapshot = await _firestore
          .collection('Data')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      print('✓ Connection successful to FitgenMedical');
      print('✓ Collection "Data" exists');
      print('✓ Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        print('\n=== Sample Data Structure from FitgenMedical ===');
        for (int i = 0; i < snapshot.docs.length; i++) {
          var doc = snapshot.docs[i];
          var data = doc.data() as Map<String, dynamic>;
          print('Document ${i + 1}:');
          print('  ID: ${doc.id}');
          print('  Data: $data');
          print('  BPM: ${data['BPM']} (${data['BPM'].runtimeType})');
          print('  IBM: ${data['IBM']} (${data['IBM'].runtimeType})');
          if (data['timestamp'] != null) {
            print(
              '  Timestamp: ${data['timestamp']} (${data['timestamp'].runtimeType})',
            );
          }
          print('---');
        }
      } else {
        print('⚠️ No documents found in Data collection of FitgenMedical');
      }
    } catch (e) {
      print('❌ Connection failed to FitgenMedical: $e');
    }
  }

  // Get real-time heart rate data from FitgenMedical with improved error handling
  static Stream<Map<String, dynamic>?> getRealtimeHeartRateStream() {
    // print('Starting real-time heart rate stream from FitgenMedical...');

    return _firestore
        .collection('FitgenMedical')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots(includeMetadataChanges: false)
        .map((snapshot) {
          print(
            'Stream update received from FitgenMedical - docs: ${snapshot.docs.length}',
          );

          if (snapshot.docs.isEmpty) {
            print('⚠️ No documents in FitgenMedical stream');
            return _createDefaultData('No data available from FitgenMedical');
          }

          var doc = snapshot.docs.first;
          var data = doc.data();

          print('Raw data received from FitgenMedical: $data');

          // Parse BPM value safely
          double bpm = _parseNumericValue(data['BPM']);
          double ibm = _parseNumericValue(data['IBM']);

          // Handle timestamp
          DateTime timestamp = _parseTimestamp(data['timestamp']);

          // Check if data is recent (within last 5 minutes)
          bool isRecent = DateTime.now().difference(timestamp).inMinutes < 5;
          bool isConnected = bpm > 30 && bpm < 200 && isRecent;

          Map<String, dynamic> result = {
            'BPM': bpm,
            'IBM': ibm,
            'timestamp': timestamp.toIso8601String(),
            'deviceId': doc.id,
            'isConnected': isConnected,
            'isRecent': isRecent,
            'rawData': data,
            'lastUpdated': DateTime.now().toIso8601String(),
            'source': 'FitgenMedical',
          };

          print(
            '✓ Processed data from FitgenMedical: BPM=$bpm, IBM=$ibm, Connected=$isConnected',
          );
          return result;
        })
        .handleError((error) {
          print('❌ Stream error from FitgenMedical: $error');
          return _createDefaultData('Stream error from FitgenMedical: $error');
        });
  }

  // Helper method to parse numeric values safely
  static double _parseNumericValue(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  // Helper method to parse timestamps
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is int) {
      // Unix timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return DateTime.now();
  }

  // Helper method to create default data
  static Map<String, dynamic> _createDefaultData(String message) {
    return {
      'BPM': 0.0,
      'IBM': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
      'deviceId': 'unknown',
      'isConnected': false,
      'isRecent': false,
      'error': message,
      'lastUpdated': DateTime.now().toIso8601String(),
      'source': 'FitgenMedical',
    };
  }

  // Get device connection status with better logic
  static Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      print('Checking device status from FitgenMedical...');

      QuerySnapshot snapshot = await _firestore
          .collection('Data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No documents found in FitgenMedical Data collection');
        return {
          'isConnected': false,
          'lastUpdate': null,
          'deviceId': 'FitgenMedical_IoT',
          'signalStrength': 'No Data',
          'batteryLevel': 0,
          'message': 'No documents found in FitgenMedical Data collection',
          'dataCount': 0,
          'minutesSinceUpdate': 9999,
          'source': 'FitgenMedical',
        };
      }

      var doc = snapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;

      DateTime lastUpdate = _parseTimestamp(data['timestamp']);
      var now = DateTime.now();
      var difference = now.difference(lastUpdate);

      // Consider connected if data is less than 5 minutes old and BPM is realistic
      double bpm = _parseNumericValue(data['BPM']);
      bool hasValidBPM = bpm > 30 && bpm < 200;
      bool isRecent = difference.inMinutes < 5;
      bool isConnected = hasValidBPM && isRecent;

      print(
        'Device status from FitgenMedical - BPM: $bpm, Minutes ago: ${difference.inMinutes}, Connected: $isConnected',
      );

      return {
        'isConnected': isConnected,
        'lastUpdate': lastUpdate,
        'minutesSinceUpdate': difference.inMinutes,
        'deviceId': 'FitgenMedical_IoT',
        'signalStrength': isConnected
            ? 'Good'
            : (isRecent ? 'Weak' : 'No Signal'),
        'batteryLevel': 85,
        'dataCount': 1,
        'lastBPM': bpm,
        'lastIBM': _parseNumericValue(data['IBM']),
        'hasValidData': hasValidBPM,
        'isRecent': isRecent,
        'source': 'FitgenMedical',
      };
    } catch (e) {
      print('❌ Error getting device status from FitgenMedical: $e');
      return {
        'isConnected': false,
        'lastUpdate': null,
        'deviceId': 'FitgenMedical_IoT',
        'signalStrength': 'Error',
        'batteryLevel': 0,
        'error': e.toString(),
        'dataCount': 0,
        'minutesSinceUpdate': 9999,
        'source': 'FitgenMedical',
      };
    }
  }

  // Get historical heart rate data from FitgenMedical
  static Future<List<Map<String, dynamic>>> getHistoricalHeartRateData({
    int limit = 50,
  }) async {
    try {
      print(
        'Fetching historical heart rate data from FitgenMedical (limit: $limit)...',
      );

      QuerySnapshot snapshot = await _firestore
          .collection('Data')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        double bpm = _parseNumericValue(data['BPM']);
        double ibm = _parseNumericValue(data['IBM']);

        // Only include realistic heart rates
        if (bpm > 30 && bpm < 200) {
          DateTime timestamp = _parseTimestamp(data['timestamp']);

          results.add({
            'id': doc.id,
            'BPM': bpm,
            'IBM': ibm,
            'timestamp': timestamp.toIso8601String(),
            'date': timestamp,
            'rawData': data,
            'source': 'FitgenMedical',
          });
        }
      }

      print(
        '✓ Valid historical HR data points from FitgenMedical: ${results.length}',
      );
      return results;
    } catch (e) {
      print('❌ Error fetching historical data from FitgenMedical: $e');
      return [];
    }
  }

  // Get heart rate statistics from FitgenMedical
  static Future<Map<String, dynamic>> getHeartRateStatistics({
    Duration period = const Duration(days: 7),
  }) async {
    try {
      List<Map<String, dynamic>> data = await getHistoricalHeartRateData(
        limit: 200,
      );

      if (data.isEmpty) {
        return {
          'average': 0.0,
          'min': 0.0,
          'max': 0.0,
          'count': 0,
          'dataPoints': [],
          'source': 'FitgenMedical',
        };
      }

      List<double> bpmValues = data
          .map((item) => (item['BPM'] as num).toDouble())
          .where((bpm) => bpm > 30 && bpm < 200)
          .toList();

      if (bpmValues.isEmpty) {
        return {
          'average': 0.0,
          'min': 0.0,
          'max': 0.0,
          'count': 0,
          'dataPoints': [],
          'source': 'FitgenMedical',
        };
      }

      bpmValues.sort();

      return {
        'average': bpmValues.reduce((a, b) => a + b) / bpmValues.length,
        'min': bpmValues.first,
        'max': bpmValues.last,
        'count': bpmValues.length,
        'period': period.inDays,
        'dataPoints': data.take(50).toList(),
        'source': 'FitgenMedical',
      };
    } catch (e) {
      print('❌ Error calculating statistics from FitgenMedical: $e');
      return {
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
        'count': 0,
        'dataPoints': [],
        'source': 'FitgenMedical',
      };
    }
  }

  // Generate ECG simulation with proper math imports
  static List<Map<String, dynamic>> generateSimulatedECGData(double heartRate) {
    List<Map<String, dynamic>> ecgPoints = [];
    int totalPoints = 100;
    double frequency = heartRate / 60.0;

    for (int i = 0; i < totalPoints; i++) {
      double time = i / 100.0;
      double voltage = _generateECGVoltage(time, frequency);

      ecgPoints.add({'voltage': voltage, 'time': time, 'index': i});
    }

    return ecgPoints;
  }

  // Fixed ECG voltage generation with proper math functions
  static double _generateECGVoltage(double time, double frequency) {
    double phase = (time * frequency) % 1.0;

    if (phase < 0.1) {
      // P wave
      return 0.1 * (1 - math.cos(2 * math.pi * phase / 0.1)) / 2;
    } else if (phase < 0.2) {
      // Flat segment
      return 0.0;
    } else if (phase < 0.25) {
      // Q wave
      return -0.05;
    } else if (phase < 0.35) {
      // R wave (main spike)
      double rPhase = (phase - 0.25) / 0.1;
      return 1.0 * math.sin(math.pi * rPhase);
    } else if (phase < 0.4) {
      // S wave
      return -0.1;
    } else if (phase < 0.6) {
      // ST segment
      return 0.0;
    } else if (phase < 0.8) {
      // T wave
      double tPhase = (phase - 0.6) / 0.2;
      return 0.3 * math.sin(math.pi * tPhase);
    } else {
      // Rest period
      return 0.0;
    }
  }

  // Test method to manually add data to FitgenMedical (for testing)
  static Future<bool> addTestHeartRateData(double bpm, double ibm) async {
    try {
      await _firestore.collection('Data').add({
        'BPM': bpm,
        'IBM': ibm,
        'timestamp': Timestamp.now(), // Use Firestore Timestamp
        'source': 'manual_test',
        'deviceId': 'test_device',
      });
      print('✓ Test data added to FitgenMedical: BPM=$bpm, IBM=$ibm');
      return true;
    } catch (e) {
      print('❌ Error adding test data to FitgenMedical: $e');
      return false;
    }
  }

  // Add method to create sample data for testing in FitgenMedical
  static Future<void> createSampleData() async {
    try {
      // Add some sample heart rate data to FitgenMedical
      List<double> sampleBPMs = [72, 75, 68, 78, 82, 69, 74];

      for (int i = 0; i < sampleBPMs.length; i++) {
        await _firestore.collection('Data').add({
          'BPM': sampleBPMs[i],
          'IBM': sampleBPMs[i] * 0.8, // IBM is typically lower than BPM
          'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: i * 5)),
          ),
          'source': 'sample_data',
          'deviceId': 'FitgenMedical_IoT',
        });
      }

      print('✓ Sample data created successfully in FitgenMedical');
    } catch (e) {
      print('❌ Error creating sample data in FitgenMedical: $e');
    }
  }

  // Cleanup method
  static void dispose() {
    _heartRateSubscription?.cancel();
  }
}
