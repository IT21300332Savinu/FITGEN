import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/ocr_service.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final bool isUpdate;

  const ProfileScreen({super.key, this.existingProfile, this.isUpdate = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedGoal = 'Weight Loss';

  // Medical conditions with maximum selection limit
  bool _hasDiabetes = false;
  String _diabetesType = 'Type 1';
  bool _hasHypertension = false;
  bool _hasCKD = false;
  bool _hasLiverDisease = false;
  bool _hasFattyLiver = false;

  final List<File> _uploadedReports = [];
  final List<Map<String, dynamic>> _processedReports = [];
  bool _isProcessing = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Maintain Healthy Life',
  ];
  final List<String> _diabetesTypes = ['Type 1', 'Type 2'];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final profile = widget.existingProfile!;
    _ageController.text = profile.age.toString();
    _heightController.text = profile.height.toString();
    _weightController.text = profile.weight.toString();
    _selectedGender = profile.gender;
    _selectedGoal = profile.personalGoal;
    _hasDiabetes = profile.diabetes;
    _diabetesType = profile.diabetesType ?? 'Type 1';
    _hasHypertension = profile.hypertension;
    _hasCKD = profile.ckd;
    _hasLiverDisease = profile.liverDisease;
    _hasFattyLiver = profile.fattyLiver;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  int get _selectedConditionsCount {
    int count = 0;
    if (_hasDiabetes) count++;
    if (_hasHypertension) count++;
    if (_hasCKD) count++;
    if (_hasLiverDisease) count++;
    if (_hasFattyLiver) count++;
    return count;
  }

  bool _canSelectCondition() {
    return _selectedConditionsCount < 2;
  }

  void _onConditionChanged(String condition, bool value) {
    if (value && !_canSelectCondition()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can select maximum 2 medical conditions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      switch (condition) {
        case 'diabetes':
          _hasDiabetes = value;
          break;
        case 'hypertension':
          _hasHypertension = value;
          break;
        case 'ckd':
          _hasCKD = value;
          break;
        case 'liverDisease':
          _hasLiverDisease = value;
          break;
        case 'fattyLiver':
          _hasFattyLiver = value;
          break;
      }
    });
  }

  Future<void> _pickImage() async {
    if (_uploadedReports.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 reports allowed')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isProcessing = true;
      });

      File imageFile = File(image.path);
      _uploadedReports.add(imageFile);

      Map<String, dynamic> ocrResult = await OCRService.processReport(
        imageFile,
      );

      if (ocrResult['success']) {
        Map<String, dynamic> extractedValues = ocrResult['extractedValues'];

        // Auto-suggest conditions based on OCR results
        Map<String, bool> conditionRisks = OCRService.assessConditionRisks(
          extractedValues,
        );
        _suggestConditionsFromOCR(conditionRisks);

        _processedReports.add({
          'file': imageFile,
          'fileName': image.name,
          'ocrResults': ocrResult['ocrResults'],
          'extractedValues': extractedValues,
        });
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _suggestConditionsFromOCR(Map<String, bool> risks) {
    List<String> suggestions = [];

    if (risks['diabetesRisk'] == true && !_hasDiabetes) {
      suggestions.add('Diabetes detected in report');
    }
    if (risks['hypertensionRisk'] == true && !_hasHypertension) {
      suggestions.add('Hypertension indicators found');
    }
    if (risks['ckdRisk'] == true && !_hasCKD) {
      suggestions.add('Kidney function concerns detected');
    }
    if (risks['liverDiseaseRisk'] == true && !_hasLiverDisease) {
      suggestions.add('Liver function abnormalities found');
    }

    if (suggestions.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Medical Report Analysis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Based on your report, we detected:'),
              const SizedBox(height: 10),
              ...suggestions.map((suggestion) => Text('• $suggestion')),
              const SizedBox(height: 10),
              const Text('Would you like to update your medical conditions?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () {
                _autoSelectConditions(risks);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    }
  }

  void _autoSelectConditions(Map<String, bool> risks) {
    if (_selectedConditionsCount >= 2) return;

    setState(() {
      if (risks['diabetesRisk'] == true && _canSelectCondition()) {
        _hasDiabetes = true;
      }
      if (risks['hypertensionRisk'] == true && _canSelectCondition()) {
        _hasHypertension = true;
      }
      if (risks['ckdRisk'] == true && _canSelectCondition()) {
        _hasCKD = true;
      }
      if (risks['liverDiseaseRisk'] == true && _canSelectCondition()) {
        _hasLiverDisease = true;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedConditionsCount == 0) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Medical Conditions'),
          content: const Text(
            'You haven\'t selected any medical conditions. This will limit personalized health insights. Continue anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Upload reports to Firebase Storage
      List<String> reportUrls = [];
      for (int i = 0; i < _processedReports.length; i++) {
        String? url = await FirebaseService.uploadReport(
          _processedReports[i]['file'],
          _processedReports[i]['fileName'],
        );
        if (url != null) {
          reportUrls.add(url);

          // Save enhanced report data to Firestore
          await FirebaseService.saveReportData({
            'fileName': _processedReports[i]['fileName'],
            'fileUrl': url,
            'ocrResults': _processedReports[i]['ocrResults'],
            'extractedValues': _processedReports[i]['extractedValues'],
            'uploadDate': DateTime.now().toIso8601String(),
            'conditionRisks': OCRService.assessConditionRisks(
              _processedReports[i]['extractedValues'],
            ),
          });
        }
      }

      // Create or update user profile
      UserProfile profile = UserProfile(
        id:
            widget.existingProfile?.id ??
            FirebaseService.getCurrentUserId() ??
            '',
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        personalGoal: _selectedGoal,
        diabetes: _hasDiabetes,
        diabetesType: _hasDiabetes ? _diabetesType : null,
        hypertension: _hasHypertension,
        ckd: _hasCKD,
        liverDisease: _hasLiverDisease,
        fattyLiver: _hasFattyLiver,
        reportUrls: reportUrls,
        createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.isUpdate) {
        success = await FirebaseService.updateUserProfile(profile);
      } else {
        success = await FirebaseService.createUserProfile(profile);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isUpdate
                  ? 'Profile updated successfully!'
                  : 'Profile created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isUpdate
                  ? 'Failed to update profile'
                  : 'Failed to create profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildConditionTile({
    required String title,
    required String description,
    required bool value,
    required String conditionKey,
    Widget? trailing,
  }) {
    bool canSelect = value || _canSelectCondition();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? Colors.orange : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: value ? Colors.orange[50] : null,
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
            color: canSelect ? Colors.black87 : Colors.grey[500],
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: canSelect ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        value: value,
        onChanged: canSelect
            ? (newValue) => _onConditionChanged(conditionKey, newValue ?? false)
            : null,
        activeColor: Colors.orange,
        secondary: trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUpdate ? 'Update Profile' : 'Create Health Profile',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange[400]!, Colors.orange[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            widget.isUpdate ? Icons.edit : Icons.person_add,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.isUpdate
                                ? 'Update Your Health Profile'
                                : 'Welcome to Smart Gym & Health',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isUpdate
                                ? 'Keep your health information up to date'
                                : 'Let\'s create your personalized health profile',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Information Section
                    Card(
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
                                border: OutlineInputBorder(),
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
                                border: OutlineInputBorder(),
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

                            // Height Input
                            TextFormField(
                              controller: _heightController,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.height),
                                suffixText: 'cm',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your height';
                                }
                                double? height = double.tryParse(value);
                                if (height == null ||
                                    height < 50 ||
                                    height > 250) {
                                  return 'Please enter a valid height';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Weight Input
                            TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.monitor_weight),
                                suffixText: 'kg',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your weight';
                                }
                                double? weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 20 ||
                                    weight > 500) {
                                  return 'Please enter a valid weight';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Personal Goal Selection
                            DropdownButtonFormField<String>(
                              value: _selectedGoal,
                              decoration: const InputDecoration(
                                labelText: 'Personal Goal',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flag),
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

                            // BMI Display (if height and weight are entered)
                            if (_heightController.text.isNotEmpty &&
                                _weightController.text.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Builder(
                                  builder: (context) {
                                    double? height = double.tryParse(
                                      _heightController.text,
                                    );
                                    double? weight = double.tryParse(
                                      _weightController.text,
                                    );
                                    if (height != null &&
                                        weight != null &&
                                        height > 0) {
                                      double bmi =
                                          weight /
                                          ((height / 100) * (height / 100));
                                      String category = bmi < 18.5
                                          ? 'Underweight'
                                          : bmi < 25
                                          ? 'Normal'
                                          : bmi < 30
                                          ? 'Overweight'
                                          : 'Obese';
                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.calculate,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'BMI: ${bmi.toStringAsFixed(1)} ($category)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Medical Conditions Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                            Text(
                              'Select up to 2 conditions that apply to you ($_selectedConditionsCount/2 selected)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),

                            // Diabetes
                            _buildConditionTile(
                              title: 'Diabetes',
                              description: 'Type 1 or Type 2 diabetes',
                              value: _hasDiabetes,
                              conditionKey: 'diabetes',
                              trailing: _hasDiabetes
                                  ? DropdownButton<String>(
                                      value: _diabetesType,
                                      onChanged: (value) {
                                        setState(() {
                                          _diabetesType = value!;
                                        });
                                      },
                                      items: _diabetesTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                    )
                                  : null,
                            ),

                            // Hypertension
                            _buildConditionTile(
                              title: 'Hypertension',
                              description: 'High blood pressure',
                              value: _hasHypertension,
                              conditionKey: 'hypertension',
                            ),

                            // CKD
                            _buildConditionTile(
                              title: 'CKD (Chronic Kidney Disease)',
                              description: 'Kidney function problems',
                              value: _hasCKD,
                              conditionKey: 'ckd',
                            ),

                            // Liver Disease
                            _buildConditionTile(
                              title: 'Liver Disease',
                              description: 'Liver function abnormalities',
                              value: _hasLiverDisease,
                              conditionKey: 'liverDisease',
                            ),

                            // Fatty Liver
                            _buildConditionTile(
                              title: 'Fatty Liver',
                              description: 'Non-alcoholic fatty liver disease',
                              value: _hasFattyLiver,
                              conditionKey: 'fattyLiver',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Report Upload Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                  'Medical Reports (Max 2)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload your medical reports for AI-powered health analysis',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              onPressed: _uploadedReports.length < 2
                                  ? _pickImage
                                  : null,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text(
                                'Upload Report ${_uploadedReports.length + 1}',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),

                            if (_processedReports.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...List.generate(_processedReports.length, (
                                index,
                              ) {
                                final report = _processedReports[index];
                                return Card(
                                  color: Colors.green[50],
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.description,
                                      color: Colors.green,
                                    ),
                                    title: Text(report['fileName']),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('OCR Processing: Complete'),
                                        if (report['extractedValues']
                                            .isNotEmpty)
                                          Text(
                                            'Detected: ${report['extractedValues'].keys.join(', ')}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
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
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.isUpdate ? 'Update Profile' : 'Create Profile',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
