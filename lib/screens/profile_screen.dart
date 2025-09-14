import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../services/meal_suggestions_service.dart';
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
  List<String> _availableConditions = const [
    'Diabetes',
    'Hypertension',
    'Chronic Kidney Disease',
    'Liver Disease',
    'Fatty Liver',
  ];

  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _user;
  File? _healthDocumentFile;
  String? _healthDocumentUrl;
  int _currentStep = 0;

  String _selectedGender = 'Male';
  final List<String> _genders = const ['Male', 'Female'];

  String _selectedActivityLevel = 'Moderately active';
  final List<String> _activityLevels = const [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Extra active',
    'Very active',
  ];

  String _selectedDietaryPreference = 'Non-veg';
  final List<String> _dietaryPreferences = const ['Veg', 'Non-veg'];

  String _selectedBudget = 'Medium';
  final List<String> _budgetPreferences = const ['Low', 'Medium', 'High'];

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
      debugPrint('Error uploading health document: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    final cs = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_user == null) return;

      final healthDocumentUrl = await _uploadHealthDocument();

      final conditions = _selectedConditions
          .map(
            (name) => MedicalCondition(
          name: name,
          description: 'User reported condition',
          severityLevel: 3,
          limitations: const [],
        ),
      )
          .toList();

      final healthMetrics = HealthMetrics(
        restingHeartRate: int.parse(_restingHeartRateController.text),
        bloodPressureSystolic: int.parse(_bloodPressureSystolicController.text),
        bloodPressureDiastolic: int.parse(_bloodPressureDiastolicController.text),
        respiratoryRate: int.parse(_respiratoryRateController.text),
        bloodGlucose: double.parse(_bloodGlucoseController.text),
      );

      final height = double.parse(_heightController.text) / 100; // cm -> m
      final weight = double.parse(_weightController.text);
      final bmi = weight / (height * height);
      debugPrint("Computed BMI: $bmi"); // if you want to use/store later

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

      // Save updatedUser with your auth/service here

      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profile updated successfully'), backgroundColor: cs.primary),
      );
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}'), backgroundColor: cs.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) setState(() => _currentStep += 1);
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  Widget _buildHealthMetricField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required String helperText,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: unit,
              helperText: helperText,
            ),
            validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: theme.appBarTheme.elevation,
        title: Text(
          'Health Profile',
          style: GoogleFonts.poppins(
            textStyle: theme.appBarTheme.titleTextStyle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: theme.appBarTheme.centerTitle ?? true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Health Profile Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  content: Text(
                    'Your health profile helps us tailor recommendations to your needs. '
                        'All medical information is kept confidential and used only to ensure your safety.',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      child: Text('OK', style: GoogleFonts.poppins(color: cs.primary)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : Form(
        key: _formKey,
        child: Theme( // Stepper inherits primary colors for connectors/icons
          data: theme.copyWith(
            colorScheme: cs,
          ),
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: _currentStep == 2 ? _updateProfile : _nextStep,
            onStepCancel: _previousStep,
            steps: [
              // Step 1: Basic Information
              Step(
                title: Text('Basic Info', style: GoogleFonts.poppins(color: cs.primary)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person, color: cs.primary),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.person_outline, color: cs.primary),
                      ),
                      items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (value) => setState(() => _selectedGender = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.calendar_today, color: cs.primary),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your age';
                        if (int.tryParse(v) == null) return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: Icon(Icons.height, color: cs.primary),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter height';
                            if (double.tryParse(v) == null) return 'Enter valid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: Icon(Icons.monitor_weight, color: cs.primary),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please enter weight';
                            if (double.tryParse(v) == null) return 'Enter valid number';
                            return null;
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Emergency Contact',
                        prefixIcon: Icon(Icons.emergency, color: cs.primary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: InputDecoration(
                        labelText: 'Activity Level',
                        prefixIcon: Icon(Icons.fitness_center, color: cs.primary),
                      ),
                      items: _activityLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (value) => setState(() => _selectedActivityLevel = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDietaryPreference,
                      decoration: InputDecoration(
                        labelText: 'Dietary Preference',
                        prefixIcon: Icon(Icons.restaurant_menu, color: cs.primary),
                      ),
                      items: _dietaryPreferences.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (value) => setState(() => _selectedDietaryPreference = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBudget,
                      decoration: InputDecoration(
                        labelText: 'Budget Preference',
                        prefixIcon: Icon(Icons.money, color: cs.primary),
                      ),
                      items: _budgetPreferences.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (value) => setState(() => _selectedBudget = value!),
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
              ),

              // Step 2: Medical Conditions
              Step(
                title: Text('Medical', style: GoogleFonts.poppins(color: cs.primary)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Conditions',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: Theme.of(context).cardTheme.shape,
                      elevation: Theme.of(context).cardTheme.elevation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Icon(Icons.medical_services, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Select All That Apply',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableConditions.map((condition) {
                              final isSelected = _selectedConditions.contains(condition);
                              return FilterChip(
                                selected: isSelected,
                                label: Text(condition, style: GoogleFonts.poppins()),
                                backgroundColor: cs.surfaceVariant.withOpacity(0.6),
                                selectedColor: cs.primary.withOpacity(0.25),
                                checkmarkColor: cs.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      if (condition == 'None') {
                                        _selectedConditions = ['None'];
                                      } else {
                                        _selectedConditions.remove('None');
                                        _selectedConditions.add(condition);
                                      }
                                    } else {
                                      _selectedConditions.remove(condition);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _medicalNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Additional Medical Notes',
                        prefixIcon: Icon(Icons.note_alt, color: cs.primary),
                        helperText: 'Include allergies, injuries, or other health concerns',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: Theme.of(context).cardTheme.shape,
                      elevation: Theme.of(context).cardTheme.elevation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Icon(Icons.upload_file, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Upload Medical Documents',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            'Upload any relevant medical reports or prescriptions.',
                            style: GoogleFonts.poppins(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickHealthDocument,
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: cs.surfaceVariant.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (_healthDocumentFile != null || _healthDocumentUrl != null)
                                      ? cs.primary
                                      : cs.outlineVariant,
                                ),
                              ),
                              child: Center(
                                child: _healthDocumentFile != null
                                    ? Image.file(_healthDocumentFile!, height: 80, fit: BoxFit.cover)
                                    : _healthDocumentUrl != null
                                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.file_present, color: cs.primary),
                                  const SizedBox(width: 8),
                                  Text('Document uploaded', style: GoogleFonts.poppins()),
                                ])
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.add_circle_outline, color: cs.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text('Tap to upload document', style: GoogleFonts.poppins(color: cs.onSurfaceVariant)),
                                ]),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Suggest Meal Plan (sample integration button)
                    ElevatedButton(
                      onPressed: () async {
                        final age = int.tryParse(_ageController.text) ?? 0;
                        final height = double.tryParse(_heightController.text) ?? 0;
                        final weight = double.tryParse(_weightController.text) ?? 0;

                        final payload = {
                          "Age": age,
                          "Gender": _selectedGender,
                          "Height": height,
                          "Weight": weight,
                          "Activity_Level": _selectedActivityLevel,
                          "Dietary_Preference": _selectedDietaryPreference,
                          "Budget_Preferences": _selectedBudget,
                          // Map your conditions here as your backend expects:
                          "Acne": _selectedConditions.contains("Liver Disease") ? 1 : 0,
                          "Diabetes": _selectedConditions.contains("Diabetes") ? 1 : 0,
                          "Heart_Disease": _selectedConditions.contains("Fatty Liver") ? 1 : 0,
                          "Hypertension": _selectedConditions.contains("Hypertension") ? 1 : 0,
                          "Kidney_Disease": _selectedConditions.contains("Chronic Kidney Disease") ? 1 : 0,
                          "Weight_Gain": _selectedConditions.contains("Weight Gain") ? 1 : 0,
                          "Weight_Loss": _selectedConditions.contains("Weight Loss") ? 1 : 0,
                        };

                        final api = ApiDio();
                        final result = await api.suggestMeal(payload);

                        if (!mounted) return;
                        if (result != null) {
                          Navigator.pushNamed(
                            context,
                            '/meal-suggestion',
                            arguments: {
                              "calories": result["predicted_calories"],
                              "meals": Map<String, dynamic>.from(result["suggested_meals"]),
                              "conditions": _selectedConditions,
                              "profile": {
                                "Diabetes": _selectedConditions.contains("Diabetes") ? 1 : 0,
                                "Hypertension": _selectedConditions.contains("Hypertension") ? 1 : 0,
                                "Heart_Disease": _selectedConditions.contains("Heart Disease") ? 1 : 0,
                                "Kidney_Disease": _selectedConditions.contains("Kidney Disease") ? 1 : 0,
                              },
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Failed to get meal suggestion'), backgroundColor: cs.error),
                          );
                        }
                      },
                      child: const Text("Suggest Meal Plan"),
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
              ),

              // Step 3: Health Metrics
              Step(
                title: Text('Metrics', style: GoogleFonts.poppins(color: cs.primary)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Metrics',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These measurements help us customize your recommendations',
                      style: GoogleFonts.poppins(color: cs.onSurfaceVariant, fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    _buildHealthMetricField(
                      controller: _restingHeartRateController,
                      label: 'Resting Heart Rate',
                      unit: 'bpm',
                      icon: Icons.favorite,
                      helperText: 'Normal range: 60-100 bpm',
                    ),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(
                        child: _buildHealthMetricField(
                          controller: _bloodPressureSystolicController,
                          label: 'Systolic BP',
                          unit: 'mmHg',
                          icon: Icons.show_chart,
                          helperText: 'Upper number',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHealthMetricField(
                          controller: _bloodPressureDiastolicController,
                          label: 'Diastolic BP',
                          unit: 'mmHg',
                          icon: Icons.show_chart,
                          helperText: 'Lower number',
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    _buildHealthMetricField(
                      controller: _respiratoryRateController,
                      label: 'Respiratory Rate',
                      unit: 'bpm',
                      icon: Icons.air,
                      helperText: 'Normal range: 12-20 breaths per minute',
                    ),
                    const SizedBox(height: 12),

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
                        text: _currentStep == 2 ? 'Update Profile' : 'Next',
                        onPressed: details.onStepContinue,
                        isLoading: _isLoading,
                        backgroundColor: cs.primary,
                        textColor: cs.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: cs.primary),
                            foregroundColor: cs.primary,
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
