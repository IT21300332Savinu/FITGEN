import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart' hide WorkoutPlan;
import '../models/workout_plan.dart' as workoutModel;
import '../widgets/CustomButton.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final workoutModel.WorkoutPlan workout;

  const WorkoutDetailScreen({Key? key, required this.workout})
    : super(key: key);

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  UserModel? _user;
  bool _isLoading = true;
  List<String> _healthModifications = [];

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

          // Generate health-based modifications
          _healthModifications = _generateExerciseModifications(
            widget.workout,
            user,
          );
        });
      } else {
        // Show error if user data is not available
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User data not available')));
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> _generateExerciseModifications(
    workoutModel.WorkoutPlan workout,
    UserModel user,
  ) {
    List<String> modifications = [];

    // Example: Add modifications based on user's health conditions
    if (user.healthMetrics.bloodPressureSystolic >= 140) {
      modifications.add('Avoid high-intensity exercises.');
    }
    if (user.healthMetrics.bloodGlucose < 4.0) {
      modifications.add('Include breaks to monitor blood glucose levels.');
    }

    return modifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : _user == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load user data',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    CustomButton(
                      text: 'Try Again',
                      onPressed: _loadUserData,
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.black,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        widget.workout.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.orange, Colors.black],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About This Workout',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.workout.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[300],
                            ),
                          ),
                          SizedBox(height: 24),
                          if (_healthModifications.isNotEmpty) ...[
                            Text(
                              'Health-Based Modifications',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            ..._healthModifications.map(
                              (mod) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '- $mod',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
