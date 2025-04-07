import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/CustomButton.dart';

class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({Key? key}) : super(key: key);

  @override
  _HealthMetricsScreenState createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  bool _isLoading = true;
  UserModel? _user;
  String _diabetesStatus = 'Unknown';
  String _hypertensionStatus = 'Unknown';
  String _kidneyStatus = 'Unknown';
  String _liverStatus = 'Unknown';

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
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.getCurrentUserData();

      if (user != null) {
        setState(() {
          _user = user;
          _analyzeHealthConditions(user);
        });
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading health data')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _analyzeHealthConditions(UserModel user) {
    // Analyze Diabetes Status based on blood glucose
    final glucose = user.healthMetrics.bloodGlucose;
    if (glucose < 3.9) {
      _diabetesStatus = 'Hypoglycemia';
    } else if (glucose <= 5.5) {
      _diabetesStatus = 'Normal';
    } else if (glucose <= 7.0) {
      _diabetesStatus = 'Prediabetes';
    } else {
      _diabetesStatus = 'Hyperglycemia';
    }

    // Analyze Hypertension Status
    final systolic = user.healthMetrics.bloodPressureSystolic;
    final diastolic = user.healthMetrics.bloodPressureDiastolic;
    if (systolic < 120 && diastolic < 80) {
      _hypertensionStatus = 'Normal';
    } else if (systolic < 130 && diastolic < 80) {
      _hypertensionStatus = 'Elevated';
    } else if (systolic < 140 || diastolic < 90) {
      _hypertensionStatus = 'Stage 1';
    } else {
      _hypertensionStatus = 'Stage 2';
    }

    // Kidney status - simplified (would use eGFR in a real app)
    final hasCKD = user.conditions.any(
      (c) => c.name == 'Chronic Kidney Disease',
    );
    _kidneyStatus = hasCKD ? 'Monitored' : 'Not assessed';

    // Liver status - simplified (would use ALT/AST in a real app)
    final hasLiver = user.conditions.any((c) => c.name == 'Fatty Liver');
    _liverStatus = hasLiver ? 'Monitored' : 'Not assessed';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'elevated':
      case 'prediabetes':
      case 'monitored':
        return Colors.amber;
      case 'stage 1':
        return Colors.orange;
      case 'stage 2':
      case 'hyperglycemia':
      case 'hypoglycemia':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required String description,
    VoidCallback? onTap,
  }) {
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              if (onTap != null) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Health Analysis',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : _user == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load health data',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    CustomButton(
                      text: 'Try Again',
                      onPressed: _loadUserData,
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Health status summary
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                child: Icon(Icons.person, color: Colors.orange),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _user!.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Last updated: ${_user!.lastHealthUpdate != null ? '${_user!.lastHealthUpdate!.day}/${_user!.lastHealthUpdate!.month}/${_user!.lastHealthUpdate!.year}' : 'Not available'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem(
                                title: 'Age',
                                value: '${_user!.age}',
                                unit: 'yrs',
                              ),
                              _statItem(
                                title: 'BMI',
                                value: '${_user!.bmi.toStringAsFixed(1)}',
                                unit: _user!.bmiCategory,
                              ),
                              _statItem(
                                title: 'Weight',
                                value: '${_user!.weight}',
                                unit: 'kg',
                              ),
                              _statItem(
                                title: 'Height',
                                value: '${_user!.height}',
                                unit: 'cm',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),
                    Text(
                      'Medical Conditions Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Chronic disease monitoring
                    _buildMetricCard(
                      title: 'Diabetes Monitor',
                      value: '${_user!.healthMetrics.bloodGlucose} mmol/L',
                      status: _diabetesStatus,
                      icon: Icons.water_drop,
                      description:
                          'Based on your blood glucose level. Normal range: 3.9-5.5 mmol/L',
                      onTap: () {
                        // Navigate to detailed diabetes management page
                      },
                    ),

                    SizedBox(height: 12),
                    _buildMetricCard(
                      title: 'Hypertension Monitor',
                      value:
                          '${_user!.healthMetrics.bloodPressureSystolic}/${_user!.healthMetrics.bloodPressureDiastolic} mmHg',
                      status: _hypertensionStatus,
                      icon: Icons.favorite,
                      description:
                          'Based on your blood pressure readings. Normal range: <120/80 mmHg',
                      onTap: () {
                        // Navigate to blood pressure history page
                      },
                    ),

                    SizedBox(height: 12),
                    _buildMetricCard(
                      title: 'Kidney Health',
                      value: _kidneyStatus,
                      status:
                          _kidneyStatus == 'Not assessed'
                              ? 'Normal'
                              : 'Monitored',
                      icon: Icons.water_damage,
                      description:
                          'CKD monitoring based on your medical history and eGFR levels.',
                    ),

                    SizedBox(height: 12),
                    _buildMetricCard(
                      title: 'Liver Health',
                      value: _liverStatus,
                      status:
                          _liverStatus == 'Not assessed'
                              ? 'Normal'
                              : 'Monitored',
                      icon: Icons.health_and_safety,
                      description:
                          'Fatty liver monitoring based on your medical history.',
                    ),

                    SizedBox(height: 24),
                    Text(
                      'Health Metrics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSmallMetricCard(
                          title: 'Heart Rate',
                          value: '${_user!.healthMetrics.restingHeartRate}',
                          unit: 'bpm',
                          icon: Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        _buildSmallMetricCard(
                          title: 'Respiratory',
                          value: '${_user!.healthMetrics.respiratoryRate}',
                          unit: 'brpm',
                          icon: Icons.air,
                          color: Colors.blue,
                        ),
                        _buildSmallMetricCard(
                          title: 'BP Systolic',
                          value:
                              '${_user!.healthMetrics.bloodPressureSystolic}',
                          unit: 'mmHg',
                          icon: Icons.trending_up,
                          color: Colors.purpleAccent,
                        ),
                        _buildSmallMetricCard(
                          title: 'BP Diastolic',
                          value:
                              '${_user!.healthMetrics.bloodPressureDiastolic}',
                          unit: 'mmHg',
                          icon: Icons.trending_down,
                          color: Colors.green,
                        ),
                      ],
                    ),

                    SizedBox(height: 24),
                    Text(
                      'Recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildRecommendationCard(),

                    SizedBox(height: 24),

                    CustomButton(
                      text: 'Update Health Data',
                      icon: Icons.health_and_safety,
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }

  Widget _statItem({
    required String title,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildSmallMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    // Determine recommendations based on health metrics
    List<Map<String, dynamic>> recommendations = [];

    // Diabetes recommendations
    if (_user!.healthMetrics.bloodGlucose > 7.0) {
      recommendations.add({
        'title': 'Manage Blood Glucose',
        'description':
            'Your blood glucose level is elevated. Focus on low-glycemic exercises like walking, swimming, and cycling.',
        'icon': Icons.directions_walk,
        'color': Colors.orange,
      });
    }

    // Hypertension recommendations
    if (_user!.healthMetrics.bloodPressureSystolic >= 130 ||
        _user!.healthMetrics.bloodPressureDiastolic >= 80) {
      recommendations.add({
        'title': 'Reduce Blood Pressure',
        'description':
            'Incorporate more aerobic exercises like brisk walking or swimming. Avoid high-intensity exercises that could spike your blood pressure.',
        'icon': Icons.favorite_border,
        'color': Colors.redAccent,
      });
    }

    // Weight management
    if (_user!.bmi >= 25) {
      recommendations.add({
        'title': 'Weight Management',
        'description':
            'Focus on a combination of cardio and strength training. Start with low-impact exercises like walking or swimming.',
        'icon': Icons.fitness_center,
        'color': Colors.green,
      });
    }

    // If no specific recommendations, add a general one
    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Maintain Healthy Activity',
        'description':
            'Your health metrics look good! Continue with a balanced mix of cardio, strength training, and flexibility exercises.',
        'icon': Icons.check_circle,
        'color': Colors.green,
      });
    }

    return Column(
      children:
          recommendations.map((rec) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (rec['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (rec['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      rec['icon'] as IconData,
                      color: rec['color'] as Color,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          rec['description'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
