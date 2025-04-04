import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  late TextEditingController _restingHeartRateController;
  late TextEditingController _bloodPressureSystolicController;
  late TextEditingController _bloodPressureDiastolicController;
  late TextEditingController _respiratoryRateController;
  late TextEditingController _bloodGlucoseController;

  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();

    _restingHeartRateController = TextEditingController();
    _bloodPressureSystolicController = TextEditingController();
    _bloodPressureDiastolicController = TextEditingController();
    _respiratoryRateController = TextEditingController();
    _bloodGlucoseController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    _restingHeartRateController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _respiratoryRateController.dispose();
    _bloodGlucoseController.dispose();

    super.dispose();
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
          _nameController.text = user.name;
          _ageController.text = user.age.toString();
          _heightController.text = user.height.toString();
          _weightController.text = user.weight.toString();

          _restingHeartRateController.text =
              user.healthMetrics.restingHeartRate.toString();
          _bloodPressureSystolicController.text =
              user.healthMetrics.bloodPressureSystolic.toString();
          _bloodPressureDiastolicController.text =
              user.healthMetrics.bloodPressureDiastolic.toString();
          _respiratoryRateController.text =
              user.healthMetrics.respiratoryRate.toString();
          _bloodGlucoseController.text =
              user.healthMetrics.bloodGlucose.toString();
        });
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user data')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_user == null) return;

      // Update health metrics
      final healthMetrics = HealthMetrics(
        restingHeartRate: int.parse(_restingHeartRateController.text),
        bloodPressureSystolic: int.parse(_bloodPressureSystolicController.text),
        bloodPressureDiastolic: int.parse(
          _bloodPressureDiastolicController.text,
        ),
        respiratoryRate: int.parse(_respiratoryRateController.text),
        bloodGlucose: double.parse(_bloodGlucoseController.text),
      );

      // Update user model
      final updatedUser = _user!.copyWith(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        healthMetrics: healthMetrics,
      );

      // Save updated user data
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateUserData(updatedUser);

      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(labelText: 'Height (cm)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(labelText: 'Weight (kg)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: Text('Update Profile'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
