import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/ocr_service.dart';
import 'dashboard_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedGoal = 'Weight Loss';
  bool _hasDiabetes = false;
  String _diabetesType = 'Type 1';
  bool _hasHypertension = false;
  bool _hasCKD = false;
  bool _hasLiverDisease = false;

  final List<File> _uploadedReports = [];
  final List<Map<String, dynamic>> _processedReports = [];
  bool _isProcessing = false;
  String? _errorMessage;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintain Healthy Life',
  ];
  final List<String> _diabetesTypes = ['Type 1', 'Type 2'];

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_uploadedReports.length >= 2) {
      _showSnackBar('Maximum 2 reports allowed', isError: true);
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isProcessing = true;
          _errorMessage = null;
        });

        File imageFile = File(image.path);
        _uploadedReports.add(imageFile);

        // Process with OCR
        Map<String, dynamic> ocrResult = await OCRService.processReport(
          imageFile,
        );

        if (ocrResult['success']) {
          _processedReports.add({
            'file': imageFile,
            'fileName': image.name,
            'ocrResults': ocrResult['ocrResults'],
            'extractedValues': ocrResult['extractedValues'],
          });
          _showSnackBar('Report processed successfully!');
        } else {
          _showSnackBar(
            'Failed to process report: ${ocrResult['error']}',
            isError: true,
          );
          _uploadedReports.removeLast(); // Remove the failed upload
        }
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
      if (_uploadedReports.isNotEmpty) {
        _uploadedReports.removeLast();
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Test Firebase connection first
      bool connectionOk = await FirebaseService.testConnection();
      if (!connectionOk) {
        throw Exception(
          'Unable to connect to Firebase. Please check your internet connection.',
        );
      }

      // Upload reports to Firebase Storage
      List<String> reportUrls = [];
      for (int i = 0; i < _processedReports.length; i++) {
        String? url = await FirebaseService.uploadReport(
          _processedReports[i]['file'],
          _processedReports[i]['fileName'],
        );

        if (url != null) {
          reportUrls.add(url);

          // Save report data to Firestore
          bool reportSaved = await FirebaseService.saveReportData({
            'fileName': _processedReports[i]['fileName'],
            'fileUrl': url,
            'ocrResults': _processedReports[i]['ocrResults'],
            'extractedValues': _processedReports[i]['extractedValues'],
            'uploadDate': DateTime.now().toIso8601String(),
          });

          if (!reportSaved) {
            print(
              'Warning: Failed to save report data for ${_processedReports[i]['fileName']}',
            );
          }
        } else {
          print(
            'Warning: Failed to upload report ${_processedReports[i]['fileName']}',
          );
        }
      }

      // Create user profile
      UserProfile profile = UserProfile(
        id: '', // Will be set in Firebase service
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        personalGoal: _selectedGoal,
        diabetes: _hasDiabetes,
        diabetesType: _hasDiabetes ? _diabetesType : null,
        hypertension: _hasHypertension,
        ckd: _hasCKD,
        liverDisease: _hasLiverDisease,
        reportUrls: reportUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success = await FirebaseService.createUserProfile(profile);

      if (success) {
        _showSnackBar('Profile created successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to create profile. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Health Profile'),
        centerTitle: true,
      ),
      body: _isProcessing
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
                      'Processing your information...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Welcome to Smart Gym & Health',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Let\'s create your personalized health profile',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    _buildErrorMessage(),

                    // Personal Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.orange[600]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Age Input
                            TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.cake),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your age';
                                }
                                int? age = int.tryParse(value);
                                if (age == null || age < 1 || age > 120) {
                                  return 'Please enter a valid age';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Gender Selection
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.wc),
                              ),
                              items: _genders.map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Personal Goal Selection
                            DropdownButtonFormField<String>(
                              value: _selectedGoal,
                              decoration: const InputDecoration(
                                labelText: 'Personal Goal',
                                prefixIcon: Icon(Icons.track_changes),
                              ),
                              items: _goals.map((goal) {
                                return DropdownMenuItem(
                                  value: goal,
                                  child: Text(goal),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGoal = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medical Conditions Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.orange[600],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Medical Conditions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Select any conditions that apply to you:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Diabetes
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Diabetes'),
                                    subtitle: const Text(
                                      'Type 1 or Type 2 diabetes',
                                    ),
                                    value: _hasDiabetes,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasDiabetes = value!;
                                      });
                                    },
                                  ),
                                  if (_hasDiabetes)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        16,
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _diabetesType,
                                        decoration: const InputDecoration(
                                          labelText: 'Diabetes Type',
                                          isDense: true,
                                        ),
                                        items: _diabetesTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _diabetesType = value!;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Other conditions
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Hypertension'),
                                    subtitle: const Text('High blood pressure'),
                                    value: _hasHypertension,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasHypertension = value!;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text(
                                      'CKD (Chronic Kidney Disease)',
                                    ),
                                    subtitle: const Text(
                                      'Kidney function problems',
                                    ),
                                    value: _hasCKD,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasCKD = value!;
                                      });
                                    },
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Liver Disease'),
                                    subtitle: const Text(
                                      'Liver function problems',
                                    ),
                                    value: _hasLiverDisease,
                                    onChanged: (value) {
                                      setState(() {
                                        _hasLiverDisease = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Report Upload Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.orange[600],
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Medical Reports (Optional)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upload up to 2 medical reports for AI analysis (Max 2)',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange[200]!,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange[50],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 48,
                                    color: Colors.orange[400],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _uploadedReports.length < 2
                                        ? _pickImage
                                        : null,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: Text(
                                      _uploadedReports.isEmpty
                                          ? 'Upload First Report'
                                          : 'Upload Second Report',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  if (_uploadedReports.length >= 2)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Maximum reports uploaded',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            if (_processedReports.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...List.generate(_processedReports.length, (
                                index,
                              ) {
                                final report = _processedReports[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: Colors.green[50],
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(
                                      report['fileName'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text('OCR Processing: Complete'),
                                          ],
                                        ),
                                        if (report['extractedValues']
                                            .isNotEmpty)
                                          Text(
                                            'Values extracted: ${report['extractedValues'].keys.join(', ')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _uploadedReports.removeAt(index);
                                          _processedReports.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
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
                        onPressed: _createProfile,
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
                            Icon(Icons.rocket_launch, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Create My Health Profile',
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

                    // Privacy Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your health data is encrypted and stored securely. We respect your privacy and will never share your personal information.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
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
}
