// lib/screens/health_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mock_wearable_provider.dart';
import '../providers/health_provider.dart';
import '../services/auth_service.dart';
import '../widgets/health_recommendation_widget.dart';
import '../widgets/medical_alert_widget.dart';
import '../widgets/wearable_control_panel.dart';

class HealthDashboard extends StatefulWidget {
  @override
  _HealthDashboardState createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final mockWearableProvider = Provider.of<MockWearableProvider>(
      context,
      listen: false,
    );

    // Get current user ID
    final userId = authService.currentUser?.uid ?? 'demo-user';

    // Start mock wearable monitoring
    mockWearableProvider.startMonitoring(userId);

    // Fetch existing health data from Firebase (optional)
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    try {
      await healthProvider.fetchUserHealthData(userId);
    } catch (e) {
      print('Error fetching health data: $e');
      // Continue anyway, we have mock data
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mockWearableProvider = Provider.of<MockWearableProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Health Tracker",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Text
                      Text(
                        "Welcome to Your Health Dashboard",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Track, monitor, and improve your health metrics in one place",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 15),

                      // Medical Alert (will only show if there's a critical condition)
                      MedicalAlertWidget(),
                      SizedBox(height: 15),

                      // Mock Wearable Controls - For demonstration
                      WearableControlPanel(),
                      SizedBox(height: 25),

                      // Health Summary
                      Text(
                        "Today's Health Summary",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Health Cards Grid - Now using Mock Wearable Data
                      GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.8,
                        children: [
                          // Heart Rate Card with Stream Builder
                          StreamBuilder<int>(
                            stream: mockWearableProvider.heartRateStream,
                            initialData: mockWearableProvider.heartRate,
                            builder: (context, snapshot) {
                              final heartRate = snapshot.data ?? 0;
                              String status = "normal";
                              if (heartRate > 100) status = "warning";
                              if (heartRate > 120) status = "critical";

                              return healthCard(
                                "Heart Rate",
                                "$heartRate BPM",
                                status,
                                Icons.favorite,
                                Colors.red,
                              );
                            },
                          ),

                          // Blood Pressure Card with Stream Builder
                          StreamBuilder<String>(
                            stream: mockWearableProvider.bloodPressureStream,
                            initialData: mockWearableProvider.bloodPressure,
                            builder: (context, snapshot) {
                              final bp = snapshot.data ?? "0/0";
                              String status = "normal";

                              // Check if systolic (first number) is high
                              final systolic =
                                  int.tryParse(bp.split('/')[0]) ?? 0;
                              if (systolic > 140) status = "warning";
                              if (systolic > 160) status = "critical";

                              return healthCard(
                                "Blood Pressure",
                                "$bp mmHg",
                                status,
                                Icons.show_chart,
                                Colors.blue,
                              );
                            },
                          ),

                          // Hydration card (static for now)
                          healthCard(
                            "Hydration",
                            "78%",
                            "warning",
                            Icons.water_drop,
                            Colors.orange,
                          ),

                          // Temperature card (static for now)
                          healthCard(
                            "Temperature",
                            "36.5°C",
                            "normal",
                            Icons.thermostat,
                            Colors.green,
                          ),

                          // Steps Card with Stream Builder
                          StreamBuilder<int>(
                            stream: mockWearableProvider.stepsStream,
                            initialData: mockWearableProvider.steps,
                            builder: (context, snapshot) {
                              final steps = snapshot.data ?? 0;
                              return healthCard(
                                "Steps",
                                "$steps steps",
                                "normal",
                                Icons.directions_walk,
                                Colors.lightBlue,
                              );
                            },
                          ),

                          // Sleep Hours Card with Stream Builder
                          StreamBuilder<double>(
                            stream: mockWearableProvider.sleepHoursStream,
                            initialData: mockWearableProvider.sleepHours,
                            builder: (context, snapshot) {
                              final sleep = snapshot.data ?? 0.0;
                              String status = "normal";
                              if (sleep < 6) status = "warning";
                              if (sleep < 4) status = "critical";

                              return healthCard(
                                "Sleep",
                                "${sleep.toStringAsFixed(1)} hours",
                                status,
                                Icons.nightlight_round,
                                Colors.purple,
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 25),

                      // Medical Guidance Section
                      Text(
                        "Medical Guidance",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Health recommendation widget
                      HealthRecommendationWidget(),
                      SizedBox(height: 25),

                      // Health Insights Section - Keep your existing section
                      Text(
                        "Health Insights",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: insightCard(
                              "Health Metrics",
                              "Your vital signs overview",
                              "View Health Data",
                              Colors.green,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: insightCard(
                              "Recommended Workout",
                              "Based on activity levels",
                              "View Workout Plan",
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Keep your existing healthCard and insightCard methods
  Widget healthCard(
    String title,
    String value,
    String status,
    IconData icon,
    Color color,
  ) {
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
              Icon(icon, color: color, size: 28),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      status == "normal"
                          ? Colors.green
                          : status == "warning"
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Widget for Insights Cards
  Widget insightCard(
    String title,
    String description,
    String buttonText,
    Color badgeColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "New",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (title == "Health Metrics") {
                Navigator.pushNamed(context, '/profile');
              } else if (title == "Recommended Workout") {
                Navigator.pushNamed(context, '/workout_planner');
              }
            },
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
