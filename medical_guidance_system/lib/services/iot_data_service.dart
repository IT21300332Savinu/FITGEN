import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/firebase_config .dart';

class IoTDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: FirebaseConfig.iotApp,
  );
  static StreamSubscription? _heartRateSubscription;

  static Future<void> initializeIoTConnection() async {
    print('IoT Firestore connection initialized');
    await testConnection();
  }

  static Future<bool> testConnection() async {
    try {
      print('Testing Firestore connection...');

      // Check if the FitgenMedical collection exists and has data
      QuerySnapshot snapshot = await _firestore
          .collection('FitgenMedical')
          .limit(1)
          .get();

      print('✓ Connection test successful');
      print('✓ Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        print('✓ Sample data: $data');
      }

      return true;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  static Future<void> debugDataCollection() async {
    try {
      print('=== IoT DEBUG: Testing connection ===');

      // Check the FitgenMedical collection structure
      QuerySnapshot snapshot = await _firestore
          .collection('FitgenMedical')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      print('✓ Connection successful');
      print('✓ Collection "FitgenMedical" exists');
      print('✓ Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        print('\n=== Sample Data Structure ===');
        for (int i = 0; i < snapshot.docs.length; i++) {
          var doc = snapshot.docs[i];
          var data = doc.data() as Map<String, dynamic>;
          print('Document ${i + 1}:');
          print('  ID: ${doc.id}');
          print('  Data: $data');

          // Check both possible field structures
          if (data['BPM'] != null) {
            print('  BPM: ${data['BPM']} (${data['BPM'].runtimeType})');
          }
          if (data['IBM'] != null) {
            print('  IBM: ${data['IBM']} (${data['IBM'].runtimeType})');
          }

          // Check for nested fields structure from your IoT device
          if (data['fields'] != null) {
            var fields = data['fields'] as Map<String, dynamic>;
            if (fields['BPM'] != null && fields['BPM']['stringValue'] != null) {
              print('  BPM (nested): ${fields['BPM']['stringValue']}');
            }
            if (fields['IBM'] != null && fields['IBM']['stringValue'] != null) {
              print('  IBM (nested): ${fields['IBM']['stringValue']}');
            }
          }

          if (data['timestamp'] != null) {
            print(
              '  Timestamp: ${data['timestamp']} (${data['timestamp'].runtimeType})',
            );
          }
          print('---');
        }
      } else {
        print('⚠️ No documents found in FitgenMedical collection');
      }
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }

  static Stream<Map<String, dynamic>?> getRealtimeHeartRateStream() {
    print('Starting real-time heart rate stream...');

    return _firestore
        .collection('FitgenMedical')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          print('Stream update received - docs: ${snapshot.docs.length}');

          if (snapshot.docs.isEmpty) {
            print('⚠️ No documents in stream');
            return _createDefaultData('No data available');
          }

          var doc = snapshot.docs.first;
          var data = doc.data();

          print('Raw data received: $data');

          // Parse BPM and IBM values from your IoT device structure
          double bpm = _parseIoTValue(data, 'BPM');
          double ibm = _parseIoTValue(data, 'IBM');

          // Handle timestamp
          DateTime timestamp =
              _parseTimestamp(data['timestamp']) ?? DateTime.now();

          // Check if data is recent (within last 2 minutes for more realistic connection)
          bool isRecent = DateTime.now().difference(timestamp).inMinutes < 2;
          bool isConnected = bpm > 50 && bpm < 150 && isRecent;

          Map<String, dynamic> result = {
            'BPM': bpm,
            'IBM': ibm,
            'timestamp': timestamp.toIso8601String(),
            'deviceId': doc.id,
            'isConnected': isConnected,
            'isRecent': isRecent,
            'rawData': data,
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          print('✓ Processed data: BPM=$bpm, IBM=$ibm, Connected=$isConnected');
          return result;
        })
        .handleError((error) {
          print('❌ Stream error: $error');
          return _createDefaultData('Stream error: $error');
        });
  }

  // Helper method to parse IoT device values (handles both direct and nested field structures)
  static double _parseIoTValue(Map<String, dynamic> data, String fieldName) {
    // Try direct field access first
    if (data[fieldName] != null) {
      return _parseNumericValue(data[fieldName]);
    }

    // Try nested fields structure (from your IoT device)
    if (data['fields'] != null) {
      var fields = data['fields'] as Map<String, dynamic>;
      if (fields[fieldName] != null &&
          fields[fieldName]['stringValue'] != null) {
        return _parseNumericValue(fields[fieldName]['stringValue']);
      }
    }

    return 0.0;
  }

  static double _parseNumericValue(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

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
    };
  }

  static Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      print('Checking device status...');

      QuerySnapshot snapshot = await _firestore
          .collection('FitgenMedical')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No documents found in FitgenMedical collection');
        return {
          'isConnected': false,
          'lastUpdate': null,
          'deviceId': 'FitgenMedical_IoT',
          'signalStrength': 'No Data',
          'batteryLevel': 0,
          'message': 'No documents found in FitgenMedical collection',
          'dataCount': 0,
          'minutesSinceUpdate': 9999,
        };
      }

      var doc = snapshot.docs.first;
      var data = doc.data() as Map<String, dynamic>;

      DateTime lastUpdate =
          _parseTimestamp(data['timestamp']) ?? DateTime.now();
      var now = DateTime.now();
      var difference = now.difference(lastUpdate);

      double bpm = _parseIoTValue(data, 'BPM');
      bool hasValidBPM = bpm > 50 && bpm < 150;
      bool isRecent = difference.inMinutes < 2;
      bool isConnected = hasValidBPM && isRecent;

      print(
        'Device status - BPM: $bpm, Minutes ago: ${difference.inMinutes}, Connected: $isConnected',
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
        'lastIBM': _parseIoTValue(data, 'IBM'),
        'hasValidData': hasValidBPM,
        'isRecent': isRecent,
      };
    } catch (e) {
      print('❌ Error getting device status: $e');
      return {
        'isConnected': false,
        'lastUpdate': null,
        'deviceId': 'FitgenMedical_IoT',
        'signalStrength': 'Error',
        'batteryLevel': 0,
        'error': e.toString(),
        'dataCount': 0,
        'minutesSinceUpdate': 9999,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getHistoricalHeartRateData({
    int limit = 50,
  }) async {
    try {
      print('Fetching historical heart rate data (limit: $limit)...');

      QuerySnapshot snapshot = await _firestore
          .collection('FitgenMedical')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        double bpm = _parseIoTValue(data, 'BPM');
        double ibm = _parseIoTValue(data, 'IBM');

        if (bpm > 50 && bpm < 150) {
          DateTime timestamp =
              _parseTimestamp(data['timestamp']) ?? DateTime.now();

          results.add({
            'id': doc.id,
            'BPM': bpm,
            'IBM': ibm,
            'timestamp': timestamp.toIso8601String(),
            'date': timestamp,
            'rawData': data,
          });
        }
      }

      print('✓ Valid historical HR data points: ${results.length}');
      return results;
    } catch (e) {
      print('❌ Error fetching historical data: $e');
      return [];
    }
  }

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
        };
      }

      List<double> bpmValues = data
          .map((item) => (item['BPM'] as num).toDouble())
          .where((bpm) => bpm > 50 && bpm < 150)
          .toList();

      if (bpmValues.isEmpty) {
        return {
          'average': 0.0,
          'min': 0.0,
          'max': 0.0,
          'count': 0,
          'dataPoints': [],
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
      };
    } catch (e) {
      print('❌ Error calculating statistics: $e');
      return {
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
        'count': 0,
        'dataPoints': [],
      };
    }
  }

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

  static double _generateECGVoltage(double time, double frequency) {
    double phase = (time * frequency) % 1.0;

    if (phase < 0.1) {
      return 0.1 * (1 - math.cos(2 * math.pi * phase / 0.1)) / 2;
    } else if (phase < 0.2) {
      return 0.0;
    } else if (phase < 0.25) {
      return -0.05;
    } else if (phase < 0.35) {
      double rPhase = (phase - 0.25) / 0.1;
      return 1.0 * math.sin(math.pi * rPhase);
    } else if (phase < 0.4) {
      return -0.1;
    } else if (phase < 0.6) {
      return 0.0;
    } else if (phase < 0.8) {
      double tPhase = (phase - 0.6) / 0.2;
      return 0.3 * math.sin(math.pi * tPhase);
    } else {
      return 0.0;
    }
  }

  static Future<bool> addTestHeartRateData(double bpm, double ibm) async {
    try {
      await _firestore.collection('FitgenMedical').add({
        'BPM': bpm,
        'IBM': ibm,
        'timestamp': Timestamp.now(),
        'source': 'manual_test',
        'deviceId': 'test_device',
      });
      print('✓ Test data added: BPM=$bpm, IBM=$ibm');
      return true;
    } catch (e) {
      print('❌ Error adding test data: $e');
      return false;
    }
  }

  static void dispose() {
    _heartRateSubscription?.cancel();
  }
}
