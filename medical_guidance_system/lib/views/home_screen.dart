import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/health_data.dart';
import 'health_dashboard.dart'; // ✅ Import the dashboard

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  HealthData? userData;
  final String userId = "test_user_123"; // Replace with actual user ID

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var data = await _firebaseService.getUserHealthData(userId);
    if (data != null) {
      setState(() {
        userData = HealthData.fromMap(data); // ✅ Fixed here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HealthDashboard()),
            );
          },
          child: const Text('Go to Health Dashboard'),
        ),
      ),
    );
  }
}
