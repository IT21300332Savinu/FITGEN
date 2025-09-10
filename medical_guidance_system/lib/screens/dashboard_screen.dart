import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:text_recognition_new/screens/fitness_assessment_screen.dart';
import 'dart:math';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/iot_data_service.dart';
import 'workout_recommendations_screen.dart';
import 'profile_screen.dart';
import 'break_screen.dart';
import '../screens/fitness_assessment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  UserProfile? _userProfile;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  // Heart Rate Animation
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  // ECG Animation
  late AnimationController _ecgAnimationController;
  List<FlSpot> _ecgData = [];

  // IoT Data
  Map<String, dynamic>? _currentIoTData;
  Map<String, dynamic> _deviceStatus = {};
  List<Map<String, dynamic>> _historicalHRData = [];
  Map<String, dynamic> _hrStatistics = {};
  DateTime? _latestReportDate;

  late final Stream<Map<String, dynamic>?> _heartRateStream;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    _heartRateStream = IoTDataService.getRealtimeHeartRateStream();
  }

  Future<void> _initializeApp() async {
    await _initializeAnimations();
    await _loadUserData();
    await _loadIoTData();
    _startECGAnimation();
  }

  Future<void> _initializeAnimations() async {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _ecgAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _startECGAnimation() {
    _ecgAnimationController.addListener(() {
      setState(() {
        _updateECGData();
      });
    });

    _ecgAnimationController.repeat();
  }

  void _updateECGData() {
    if (_currentIoTData != null) {
      double heartRate = (_currentIoTData!['BPM'] ?? 75).toDouble();
      _ecgData = IoTDataService.generateSimulatedECGData(heartRate)
          .map(
            (point) =>
                FlSpot(point['index'].toDouble(), point['voltage'] + 0.5),
          )
          .toList();
    }
  }

  Future<void> _loadIoTData() async {
    try {
      // Initialize IoT connection
      await IoTDataService.initializeIoTConnection();

      // Test the connection
      bool connected = await IoTDataService.testConnection();
      print('IoT Connection test result: $connected');

      // Load device status
      _deviceStatus = await IoTDataService.getDeviceStatus();
      print('Device status: $_deviceStatus');

      // Load historical data for graphs
      _historicalHRData = await IoTDataService.getHistoricalHeartRateData(
        limit: 50,
      );
      print('Historical HR data points: ${_historicalHRData.length}');

      // Get statistics
      _hrStatistics = await IoTDataService.getHeartRateStatistics();
      print('HR Statistics: $_hrStatistics');

      setState(() {});
    } catch (e) {
      print('Error loading IoT data: $e');
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _ecgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userProfile = await FirebaseService.getUserProfile();
      _reports = await FirebaseService.getUserReports();
      _latestReportDate = await FirebaseService.getLatestReportDate();
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToUpdateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(existingProfile: _userProfile, isUpdate: true),
      ),
    ).then((_) => _loadUserData());
  }

  void _navigateToWorkoutPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FitnessAssessmentScreen(userProfile: _userProfile),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile != null
                          ? 'Welcome back, ${_userProfile!.username.isNotEmpty ? _userProfile!.username : (_userProfile!.gender == 'Male' ? 'Mr.' : 'Ms.') + ' User'}!'
                          : 'Welcome back!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userProfile != null
                          ? 'Monitoring your health with IoT technology'
                          : 'Your health journey continues...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Reports',
            '${_reports.length}',
            Icons.description,
            Colors.blue,
          ),
        ),

        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'BMI',
            _userProfile != null ? _userProfile!.bmi.toStringAsFixed(1) : '0',
            Icons.monitor_weight,
            _getBMIColor(),
          ),
        ),
      ],
    );
  }

  Color _getBMIColor() {
    if (_userProfile == null) return Colors.grey;
    double bmi = _userProfile!.bmi;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildIoTHeartRateCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.red[50]!, Colors.pink[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.monitor_heart,
                      color: Colors.red[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      ' Heart Rate Monitor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _deviceStatus['isConnected'] == true
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_deviceStatus['isConnected'] == true
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    _deviceStatus['isConnected'] == true
                        ? 'Connected to FitgenMedical '
                        : 'Disconnected from  Device',
                    style: TextStyle(
                      color: _deviceStatus['isConnected'] == true
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (_deviceStatus['minutesSinceUpdate'] != null &&
                      _deviceStatus['minutesSinceUpdate'] >= 0)
                    Text(
                      '${_deviceStatus['minutesSinceUpdate']}m ago',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              StreamBuilder<Map<String, dynamic>?>(
                stream: _heartRateStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorWidget('Stream Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return _buildNoDataWidget();
                  }

                  _currentIoTData = snapshot.data!;

                  double currentBPM = (_currentIoTData?['BPM'] ?? 0).toDouble();

                  if (currentBPM > 0 &&
                      !_heartAnimationController.isAnimating) {
                    _startHeartAnimation(currentBPM);
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _heartAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartAnimation.value,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentBPM.toInt()}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text(
                                'BPM',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IBM: ${_currentIoTData?['IBM'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${_getHeartRateStatus(currentBPM)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getHeartRateStatusColor(currentBPM),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getHeartRateStatusColor(currentBPM),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getHeartRateStatus(currentBPM),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildECGChart(currentBPM),
                      const SizedBox(height: 20),

                      _buildDataInfoRow(),
                      const SizedBox(height: 12),
                      _buildHighHeartRateHint(currentBPM),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalHRChart() {
    // Prepare data for chart (last 20 points for readability)
    List<Map<String, dynamic>> chartData = _historicalHRData
        .take(20)
        .toList()
        .reversed
        .toList();

    List<FlSpot> hrSpots = [];
    for (int i = 0; i < chartData.length; i++) {
      double bpm = chartData[i]['BPM']?.toDouble() ?? 0.0;
      if (bpm > 0) {
        hrSpots.add(FlSpot(i.toDouble(), bpm));
      }
    }

    if (hrSpots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'No valid heart rate data available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    double minY = hrSpots.map((spot) => spot.y).reduce(min) - 10;
    double maxY = hrSpots.map((spot) => spot.y).reduce(max) + 10;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Heart Rate History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last ${chartData.length} readings',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index < chartData.length) {
                            String ts = chartData[index]['timestamp'];
                            DateTime time;
                            try {
                              time = DateTime.parse(ts);
                            } catch (_) {
                              time = DateTime.now();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  minX: 0,
                  maxX: (chartData.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: hrSpots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.red[600]!,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.red[200]!.withOpacity(0.3),
                            Colors.red[100]!.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Row
            if (_hrStatistics.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatistic(
                    'Avg',
                    '${_hrStatistics['average']?.toStringAsFixed(0) ?? '0'} BPM',
                  ),
                  _buildStatistic(
                    'Min',
                    '${_hrStatistics['min']?.toStringAsFixed(0) ?? '0'} BPM',
                  ),
                  _buildStatistic(
                    'Max',
                    '${_hrStatistics['max']?.toStringAsFixed(0) ?? '0'} BPM',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistic(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildECGChart(double heartRate) {
    if (_ecgData.isEmpty) {
      _ecgData = IoTDataService.generateSimulatedECGData(heartRate)
          .map(
            (point) =>
                FlSpot(point['index'].toDouble(), point['voltage'] + 0.5),
          )
          .toList();
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE ECG - ${heartRate.toInt()} BPM',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 10,
                    horizontalInterval: 0.2,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.green.withOpacity(0.2),
                        strokeWidth: 0.5,
                      );
                    },
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.green.withOpacity(0.2),
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 100,
                  minY: 0,
                  maxY: 1.5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _ecgData,
                      isCurved: false,
                      color: Colors.green,
                      barWidth: 2,
                      isStrokeCapRound: false,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Updated',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              _currentIoTData != null
                  ? _formatDateTime(_currentIoTData!['timestamp'])
                  : 'Never',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Device',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 4),
                  Text(
                    'FitgenMedical',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 16),
          Text(
            'Connecting to IoT Device...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Connection Error',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadIoTData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No IoT Data Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your FitgenMedical device connection.\nData collection: ${_deviceStatus['dataCount'] ?? 0} records',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadIoTData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _startHeartAnimation(double heartRate) {
    if (heartRate <= 0) return;

    int bpm = heartRate.toInt();
    Duration duration = Duration(milliseconds: (60000 / bpm).round());

    _heartAnimationController.duration = duration;
    _heartAnimationController.repeat(reverse: true);
  }

  Color _getHeartRateStatusColor(double heartRate) {
    if (heartRate < 60) return Colors.blue;
    if (heartRate > 100) return Colors.red;
    return Colors.green;
  }

  String _getHeartRateStatus(double heartRate) {
    if (heartRate < 60) return 'Low (Bradycardia)';
    if (heartRate > 100) return 'High (Tachycardia)';
    return 'Normal';
  }

  bool _shouldShowReportReminder() {
    if (_latestReportDate == null) return true; // Never uploaded
    final nextDue = _latestReportDate!.add(const Duration(days: 90));
    final now = DateTime.now();
    return now.isAfter(nextDue.subtract(const Duration(days: 7)));
  }

  Widget _buildReportReminderBanner() {
    final dueText = _latestReportDate == null
        ? 'No report uploaded yet'
        : 'Last report: ${_latestReportDate!.toLocal().toString().split(' ').first}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.notification_important, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Time to re-upload your medical report (every 3 months). $dueText',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: _navigateToUpdateProfile,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Widget _buildHighHeartRateHint(double bpm) {
    if (bpm <= 100) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Heart rate is high. Consider taking a short break.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BreakScreen(bpm: bpm.toInt()),
                ),
              );
            },
            child: const Text('Take Break'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'Never';
    try {
      if (timestamp is String) {
        return DateTime.parse(timestamp).toLocal().toString();
      } else if (timestamp is DateTime) {
        return timestamp.toLocal().toString();
      } else if (timestamp is int) {
        // Unix timestamp
        return DateTime.fromMillisecondsSinceEpoch(
          timestamp,
        ).toLocal().toString();
      }
    } catch (e) {
      return 'Invalid';
    }
    return 'Never';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadUserData();
              _loadIoTData();
            },
            tooltip: 'Refresh All Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadUserData();
                await _loadIoTData();
              },
              color: Colors.orange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(),
                    const SizedBox(height: 20),

                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 20),

                    // IoT Heart Rate Monitor (MAIN FEATURE)
                    _buildIoTHeartRateCard(),
                    const SizedBox(height: 20),

                    // Historical HR Chart (NEW FEATURE)
                    _buildHistoricalHRChart(),
                    const SizedBox(height: 20),

                    // Action Buttons Section
                    Row(
                      children: [
                        // Update Profile Button
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _navigateToUpdateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Workout Plan Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _navigateToWorkoutPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'View Workout Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Report Reminder Section
                    if (_shouldShowReportReminder()) ...[
                      const SizedBox(height: 20),
                      _buildReportReminderBanner(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
