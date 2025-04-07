import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../widgets/CustomButton.dart';

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
  late TextEditingController _emergencyContactController;
  late TextEditingController _medicalNotesController;

  // Health metrics controllers
  late TextEditingController _restingHeartRateController;
  late TextEditingController _bloodPressureSystolicController;
  late TextEditingController _bloodPressureDiastolicController;
  late TextEditingController _respiratoryRateController;
  late TextEditingController _bloodGlucoseController;

  // Medical condition controllers
  List<String> _selectedConditions = [];
  List<String> _availableConditions = [
    'Diabetes',
    'Hypertension',
    'hyperclolesterolemia',
    'Chronic Kidney Disease',
    'Fatty Liver',
  ];

  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _user;
  File? _healthDocumentFile;
  String? _healthDocumentUrl;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _medicalNotesController = TextEditingController();

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
    _emergencyContactController.dispose();
    _medicalNotesController.dispose();

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
          _emergencyContactController.text = user.emergencyContact ?? '';
          _medicalNotesController.text = user.medicalNotes ?? '';
          _healthDocumentUrl = user.healthDocumentUrl;

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

          // Load selected conditions
          _selectedConditions =
              user.conditions.map((condition) => condition.name).toList();
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

  Future<void> _pickHealthDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _healthDocumentFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadHealthDocument() async {
    if (_healthDocumentFile == null) return _healthDocumentUrl;

    try {
      final userId = _user!.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('health_documents')
          .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_healthDocumentFile!);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading health document: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_user == null) return;

      // Upload health document if selected
      final healthDocumentUrl = await _uploadHealthDocument();

      // Create medical conditions from selected conditions
      final conditions =
          _selectedConditions
              .map(
                (name) => MedicalCondition(
                  name: name,
                  description: 'User reported condition',
                  severityLevel: 3, // Default severity
                  limitations: [],
                ),
              )
              .toList();

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

      // Calculate BMI
      final height = double.parse(_heightController.text) / 100; // cm to m
      final weight = double.parse(_weightController.text);
      final bmi = weight / (height * height);

      // Update user model
      final updatedUser = _user!.copyWith(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        emergencyContact: _emergencyContactController.text,
        medicalNotes: _medicalNotesController.text,
        healthDocumentUrl: healthDocumentUrl,
        conditions: conditions,
        healthMetrics: healthMetrics,
      );

      // Save updated user data
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateUserData(updatedUser);

      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Widget _buildHealthMetricField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required String helperText,
  }) {
    return Card(
      elevation: 2,
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                suffixText: unit,
                suffixStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                filled: true,
                fillColor: Colors.grey[800],
                helperText: helperText,
                helperStyle: TextStyle(color: Colors.grey[400]),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ],
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
          'Health Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.orange),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: Text(
                        'Health Profile Information',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Your health profile helps us tailor workout recommendations to your specific needs. '
                        'All medical information is kept confidential and used only to ensure your safety during workouts.',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.orange),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange))
              : Form(
                key: _formKey,
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue:
                      _currentStep == 2 ? _updateProfile : _nextStep,
                  onStepCancel: _previousStep,
                  steps: [
                    // Step 1: Basic Information
                    Step(
                      title: Text(
                        'Basic Info',
                        style: TextStyle(color: Colors.orange),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Details',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.orange,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              filled: true,
                              fillColor: Colors.grey[900],
                            ),
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
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Age',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.calendar_today,
                                color: Colors.orange,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              filled: true,
                              fillColor: Colors.grey[900],
                            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Height (cm)',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(
                                      Icons.height,
                                      color: Colors.orange,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[700]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[900],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter height';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Enter valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Weight (kg)',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    prefixIcon: Icon(
                                      Icons.monitor_weight,
                                      color: Colors.orange,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[700]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[900],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter weight';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Enter valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyContactController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Emergency Contact',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.emergency,
                                color: Colors.orange,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              filled: true,
                              fillColor: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),

                    // Step 2: Medical Conditions
                    Step(
                      title: Text(
                        'Medical',
                        style: TextStyle(color: Colors.orange),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Conditions',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.medical_services,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Select All That Apply',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        _availableConditions.map((condition) {
                                          final isSelected = _selectedConditions
                                              .contains(condition);
                                          return FilterChip(
                                            selected: isSelected,
                                            label: Text(condition),
                                            backgroundColor: Colors.grey[800],
                                            selectedColor: Colors.orange
                                                .withOpacity(0.3),
                                            checkmarkColor: Colors.orange,
                                            labelStyle: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : Colors.grey[400],
                                            ),
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  if (condition == 'None') {
                                                    _selectedConditions = [
                                                      'None',
                                                    ];
                                                  } else {
                                                    _selectedConditions.remove(
                                                      'None',
                                                    );
                                                    _selectedConditions.add(
                                                      condition,
                                                    );
                                                  }
                                                } else {
                                                  _selectedConditions.remove(
                                                    condition,
                                                  );
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _medicalNotesController,
                            maxLines: 3,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Additional Medical Notes',
                              labelStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.note_alt,
                                color: Colors.orange,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[700]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.orange),
                              ),
                              filled: true,
                              fillColor: Colors.grey[900],
                              helperText:
                                  'Include allergies, injuries, or other health concerns',
                              helperStyle: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.upload_file,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Upload Medical Documents',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Upload any relevant medical reports or prescriptions.',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  SizedBox(height: 16),
                                  InkWell(
                                    onTap: _pickHealthDocument,
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              _healthDocumentFile != null ||
                                                      _healthDocumentUrl != null
                                                  ? Colors.orange
                                                  : Colors.grey[700]!,
                                        ),
                                      ),
                                      child: Center(
                                        child:
                                            _healthDocumentFile != null
                                                ? Image.file(
                                                  _healthDocumentFile!,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                )
                                                : _healthDocumentUrl != null
                                                ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.file_present,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Document uploaded',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.add_circle_outline,
                                                      color: Colors.grey[400],
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Tap to upload document',
                                                      style: TextStyle(
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),

                    // Step 3: Health Metrics
                    Step(
                      title: Text(
                        'Metrics',
                        style: TextStyle(color: Colors.orange),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health Metrics',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'These measurements help us customize your workout recommendations',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildHealthMetricField(
                            controller: _restingHeartRateController,
                            label: 'Resting Heart Rate',
                            unit: 'bpm',
                            icon: Icons.favorite,
                            helperText: 'Normal range: 60-100 bpm',
                          ),
                          SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildHealthMetricField(
                                  controller: _bloodPressureSystolicController,
                                  label: 'Systolic BP',
                                  unit: 'mmHg',
                                  icon: Icons.show_chart,
                                  helperText: 'Upper number',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildHealthMetricField(
                                  controller: _bloodPressureDiastolicController,
                                  label: 'Diastolic BP',
                                  unit: 'mmHg',
                                  icon: Icons.show_chart,
                                  helperText: 'Lower number',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          _buildHealthMetricField(
                            controller: _respiratoryRateController,
                            label: 'Respiratory Rate',
                            unit: 'bpm',
                            icon: Icons.air,
                            helperText:
                                'Normal range: 12-20 breaths per minute',
                          ),
                          SizedBox(height: 12),

                          _buildHealthMetricField(
                            controller: _bloodGlucoseController,
                            label: 'Blood Glucose',
                            unit: 'mmol/L',
                            icon: Icons.water_drop,
                            helperText: 'Normal fasting: 3.9-5.5 mmol/L',
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),
                  ],
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text:
                                  _currentStep == 2 ? 'Update Profile' : 'Next',
                              onPressed: details.onStepContinue,
                              isLoading: _isLoading,
                              backgroundColor: Colors.orange,
                              textColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.orange),
                                  foregroundColor: Colors.orange,
                                ),
                                child: Text('Back'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
