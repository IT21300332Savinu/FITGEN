// file: lib/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  int _age = 30;
  double _weight = 70.0; // kg
  double _height = 170.0; // cm
  String _fitnessGoal = 'weight_loss'; // Default goal
  final List<String> _selectedHealthConditions = [];

  // Health condition options
  final List<String> _healthConditions = [
    'None',
    'Asthma',
    'Diabetes',
    'Heart Condition',
    'High Blood Pressure',
    'Joint Pain',
    'Back Pain',
    'Pregnancy',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Your Profile'), elevation: 0),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          'Tell us about yourself',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'This information helps us personalize your fitness experience',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[900]),
                            ),
                          ),

                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Age section
                        Text(
                          'Age: $_age years',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _age.toDouble(),
                          min: 16,
                          max: 80,
                          divisions: 64,
                          label: _age.toString(),
                          onChanged: (double value) {
                            setState(() {
                              _age = value.round();
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Weight section
                        Text(
                          'Weight: ${_weight.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _weight,
                          min: 40,
                          max: 150,
                          divisions: 110,
                          label: _weight.toStringAsFixed(1),
                          onChanged: (double value) {
                            setState(() {
                              _weight = double.parse(value.toStringAsFixed(1));
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Height section
                        Text(
                          'Height: ${_height.toStringAsFixed(1)} cm',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _height,
                          min: 140,
                          max: 220,
                          divisions: 80,
                          label: _height.toStringAsFixed(1),
                          onChanged: (double value) {
                            setState(() {
                              _height = double.parse(value.toStringAsFixed(1));
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Fitness Goal section
                        const Text(
                          'Fitness Goal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildFitnessGoalSelector(),
                        const SizedBox(height: 24),

                        // Health Conditions section
                        const Text(
                          'Health Conditions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildHealthConditionsSelector(),
                        const SizedBox(height: 32),

                        // Submit button
                        ElevatedButton(
                          onPressed: _handleProfileSubmit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'SAVE PROFILE',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildFitnessGoalSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildGoalOption(
            title: 'Weight Loss',
            description: 'Burn calories and reduce body fat',
            value: 'weight_loss',
          ),
          const Divider(height: 1),
          _buildGoalOption(
            title: 'Muscle Gain',
            description: 'Build strength and increase muscle mass',
            value: 'muscle_gain',
          ),
          const Divider(height: 1),
          _buildGoalOption(
            title: 'General Fitness',
            description: 'Improve overall health and wellness',
            value: 'general_fitness',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({
    required String title,
    required String description,
    required String value,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(description),
      value: value,
      groupValue: _fitnessGoal,
      onChanged: (newValue) {
        setState(() {
          _fitnessGoal = newValue!;
        });
      },
    );
  }

  Widget _buildHealthConditionsSelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView(
        children:
            _healthConditions.map((condition) {
              return CheckboxListTile(
                title: Text(condition),
                value: _selectedHealthConditions.contains(condition),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      if (condition == 'None') {
                        _selectedHealthConditions.clear();
                      } else {
                        _selectedHealthConditions.remove('None');
                      }
                      _selectedHealthConditions.add(condition);
                    } else {
                      _selectedHealthConditions.remove(condition);
                    }
                  });
                },
              );
            }).toList(),
      ),
    );
  }

  Future<void> _handleProfileSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'Not logged in. Please login again.';
          _isLoading = false;
        });
        return;
      }

      // Filter out 'None' if other health conditions are selected
      final healthConditions =
          _selectedHealthConditions.contains('None')
              ? ['None']
              : _selectedHealthConditions;

      // Create user profile
      final userProfile = UserProfile(
        userId: user.uid,
        name: _nameController.text,
        age: _age,
        weight: _weight,
        height: _height,
        fitnessGoal: _fitnessGoal,
        healthConditions: healthConditions,
        preferences: {},
      );

      // Save profile to Firestore
      await firebaseService.createUserProfile(userProfile);

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
