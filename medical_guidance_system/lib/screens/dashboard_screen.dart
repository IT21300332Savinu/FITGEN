import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/health_data.dart';
import '../services/firebase_service.dart';
import '../services/ocr_service.dart';
import 'workout_recommendations_screen.dart';
import 'profile_creation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _userProfile;
  List<Map<String, dynamic>> _reports = [];
  List<HealthData> _recentHealthData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile
      _userProfile = await FirebaseService.getUserProfile();
      print('Profile loaded: ${_userProfile != null}');

      // Load user reports
      _reports = await FirebaseService.getUserReports();
      print('Reports loaded: ${_reports.length}');

      // Load recent health data
      _recentHealthData = await FirebaseService.getLatestHealthData(limit: 10);
      print('Health data loaded: ${_recentHealthData.length}');
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userProfile != null
                          ? 'Ready to achieve your ${_userProfile!.personalGoal.toLowerCase()} goal?'
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
            'Health Data',
            '${_recentHealthData.length}',
            Icons.monitor_heart,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Age',
            '${_userProfile?.age ?? 0}',
            Icons.cake,
            Colors.purple,
          ),
        ),
      ],
    );
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

  Widget _buildHealthMetricsCard() {
    if (_reports.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.upload_file, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text(
                'No Medical Reports Yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your medical reports to get AI-powered health insights',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Get latest report
    Map<String, dynamic> latestReport = _reports.first;
    Map<String, dynamic> extractedValues =
        latestReport['extractedValues'] ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Latest Report Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (extractedValues['hba1c'] != null)
              _buildMetricRow(
                'HbA1c',
                '${extractedValues['hba1c'].toStringAsFixed(1)}%',
                _getHbA1cStatus(extractedValues['hba1c']),
                'Diabetes control indicator',
              ),
            if (extractedValues['glucose'] != null)
              _buildMetricRow(
                'Glucose',
                '${extractedValues['glucose'].toStringAsFixed(0)} ${extractedValues['glucoseUnit'] ?? 'mg/dL'}',
                _getGlucoseStatus(extractedValues['glucose']),
                'Blood sugar level',
              ),
            if (extractedValues['systolicBP'] != null &&
                extractedValues['diastolicBP'] != null)
              _buildMetricRow(
                'Blood Pressure',
                '${extractedValues['systolicBP']}/${extractedValues['diastolicBP']} mmHg',
                _getBPStatus(
                  extractedValues['systolicBP'],
                  extractedValues['diastolicBP'],
                ),
                'Cardiovascular health',
              ),
            if (extractedValues['cholesterol'] != null)
              _buildMetricRow(
                'Total Cholesterol',
                '${extractedValues['cholesterol'].toStringAsFixed(0)} ${extractedValues['cholesterolUnit'] ?? 'mg/dL'}',
                _getCholesterolStatus(extractedValues['cholesterol']),
                'Heart health indicator',
              ),
            if (extractedValues['hdl'] != null)
              _buildMetricRow(
                'HDL Cholesterol',
                '${extractedValues['hdl'].toStringAsFixed(0)} ${extractedValues['hdlUnit'] ?? 'mg/dL'}',
                _getHDLStatus(extractedValues['hdl']),
                'Good cholesterol',
              ),
            if (extractedValues['creatinine'] != null)
              _buildMetricRow(
                'Creatinine',
                '${extractedValues['creatinine'].toStringAsFixed(1)} ${extractedValues['creatinineUnit'] ?? 'mg/dL'}',
                _getCreatinineStatus(extractedValues['creatinine']),
                'Kidney function',
              ),
            if (extractedValues.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Report processed but no specific health values were extracted. Please ensure your report contains numerical health data.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color statusColor,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHbA1cStatus(double hba1c) {
    if (hba1c < 5.7) return Colors.green;
    if (hba1c < 6.5) return Colors.orange;
    return Colors.red;
  }

  Color _getGlucoseStatus(double glucose) {
    if (glucose < 100) return Colors.green;
    if (glucose < 126) return Colors.orange;
    return Colors.red;
  }

  Color _getBPStatus(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return Colors.green;
    if (systolic < 140 || diastolic < 90) return Colors.orange;
    return Colors.red;
  }

  Color _getCholesterolStatus(double cholesterol) {
    if (cholesterol < 200) return Colors.green;
    if (cholesterol < 240) return Colors.orange;
    return Colors.red;
  }

  Color _getHDLStatus(double hdl) {
    if (hdl >= 40) return Colors.green;
    return Colors.orange;
  }

  Color _getCreatinineStatus(double creatinine) {
    if (creatinine <= 1.3) return Colors.green;
    if (creatinine <= 2.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRealtimeHealthData() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Real-time Health Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<HealthData>>(
              stream: FirebaseService.getHealthDataStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sensors_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Real-time Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect your health devices to see live data',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                HealthData latestData = snapshot.data!.first;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[50]!, Colors.pink[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Heart Rate',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${latestData.heartRate.toInt()} BPM',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Updated',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatDateTime(latestData.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Source',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: latestData.source == 'esp32'
                                  ? Colors.green[100]
                                  : Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              latestData.source.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: latestData.source == 'esp32'
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInsights() {
    if (_reports.isEmpty) {
      return const SizedBox.shrink();
    }

    Map<String, dynamic> latestReport = _reports.first;
    Map<String, dynamic> extractedValues =
        latestReport['extractedValues'] ?? {};

    String insights = OCRService.getHealthInsight(
      extractedValues,
      _userProfile?.diabetes ?? false,
      _userProfile?.hypertension ?? false,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'AI Health Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                insights.isNotEmpty
                    ? insights
                    : 'No specific insights available',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Age', '${_userProfile!.age} years', Icons.cake),
            _buildInfoRow('Gender', _userProfile!.gender, Icons.wc),
            _buildInfoRow('Goal', _userProfile!.personalGoal, Icons.flag),
            const SizedBox(height: 12),
            const Text(
              'Medical Conditions:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                if (_userProfile!.diabetes)
                  _buildConditionChip(
                    'Diabetes (${_userProfile!.diabetesType})',
                    Colors.red,
                  ),
                if (_userProfile!.hypertension)
                  _buildConditionChip('Hypertension', Colors.orange),
                if (_userProfile!.ckd)
                  _buildConditionChip('Chronic Kidney Disease', Colors.purple),
                if (_userProfile!.liverDisease)
                  _buildConditionChip('Liver Disease', Colors.brown),
                if (!_userProfile!.diabetes &&
                    !_userProfile!.hypertension &&
                    !_userProfile!.ckd &&
                    !_userProfile!.liverDisease)
                  _buildConditionChip('None reported', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String condition, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        condition,
        style: TextStyle(
          color: _getColorShade700(color),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method to get darker shade of color (replaces .shade700)
  Color _getColorShade700(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor.withLightness(0.3).toColor();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading your health dashboard...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserData,
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

                    // Personal Information
                    _buildPersonalInfo(),
                    const SizedBox(height: 16),

                    // Health Metrics from Reports
                    _buildHealthMetricsCard(),
                    const SizedBox(height: 16),

                    // Real-time Health Data
                    _buildRealtimeHealthData(),
                    const SizedBox(height: 16),

                    // AI Health Insights
                    _buildHealthInsights(),
                    const SizedBox(height: 24),

                    // Workout Recommendations Button
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutRecommendationsScreen(
                                    userProfile: _userProfile,
                                    latestReportData: _reports.isNotEmpty
                                        ? _reports.first
                                        : null,
                                  ),
                            ),
                          );
                        },
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
                              'Get Workout Recommendations',
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
                    const SizedBox(height: 16),

                    // NEW: Profile Creation Button (Added Here)
                    Container(
                      width: double.infinity,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfileCreationScreen(),
                            ),
                          );
                        },
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
                              Icons.person_add,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Go to Profile Creation',
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
                    const SizedBox(height: 16),

                    // Additional Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to add new report screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Add new report feature coming soon!',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text(
                                'Add Report',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to health tracking screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Health tracking feature coming soon!',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.orange,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.track_changes),
                              label: const Text(
                                'Track Health',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Health Tip of the Day
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.cyan[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Health Tip of the Day',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getHealthTip(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getHealthTip() {
    final tips = [
      "Drink at least 8 glasses of water daily to stay hydrated and support your metabolism.",
      "Aim for 150 minutes of moderate exercise per week to maintain cardiovascular health.",
      "Include colorful fruits and vegetables in your diet for essential vitamins and antioxidants.",
      "Get 7-9 hours of quality sleep each night to support your immune system and mental health.",
      "Practice deep breathing exercises for 5 minutes daily to reduce stress and improve focus.",
      "Take regular breaks from sitting - stand and move for 2 minutes every hour.",
      "Limit processed foods and choose whole, natural ingredients for better nutrition.",
      "Regular health check-ups can help detect and prevent health issues early.",
    ];

    final now = DateTime.now();
    final index = now.day % tips.length;
    return tips[index];
  }
}
