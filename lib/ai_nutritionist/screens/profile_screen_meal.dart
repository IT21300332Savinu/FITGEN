import 'package:fitgen/flutter_flow/nav/nav.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/nutri_firebase_config.dart';
import '../services/meal_suggestions_service.dart';
import 'meal_suggestion_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  // Dropdown Selections
  String _selectedActivityLevel = 'Moderately active';
  String _selectedDietaryPreference = 'Non-veg';
  String _selectedBudget = 'Medium';

  final List<String> _activityLevels = const [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Extra active',
    'Very active',
  ];

  final List<String> _dietaryPreferences = const ['Veg', 'Non-veg'];

  final List<String> _budgetPreferences = const ['Low', 'Medium', 'High'];

  final List<String> _selectedConditions = [];

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _suggestMealPlan() async {
    final cs = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await NutriFirebaseConfig.initializeFirebase();

      final uid = "sKr1Ay7QOIcys7kzE0lJYkiNbyG3"; // Replace later with actual user ID
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;

      final profileData = {
        "Height": height,
        "Weight": weight,
        "Activity_Level": _selectedActivityLevel,
        "Dietary_Preference": _selectedDietaryPreference,
        "Budget_Preferences": _selectedBudget,
      };

      // 🔥 Update Firebase under nutrition app
      await FirebaseDatabase.instanceFor(app: NutriFirebaseConfig.nutritionApp)
          .ref("users/$uid/profile")
          .update(profileData);

      // 🌐 Call backend for meal suggestions
      final api = ApiDio();
      final result = await api.suggestMeal(uid);

      if (!context.mounted) return;

      if (result == null || result["suggested_meals"] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Meal suggestion unavailable — please check your connection.',
            ),
            backgroundColor: cs.error,
          ),
        );
        return;
      }

      // 👇 Shared data payload
      final extras = {
        "predictedCalories": (result["predicted_calories"] ?? 0).toDouble(),
        "suggestedMeals":
        Map<String, dynamic>.from(result["suggested_meals"] ?? {}),
        "conditions": _selectedConditions,
        "profile": {
          "Diabetes": _selectedConditions.contains("Diabetes") ? 1 : 0,
          "Hypertension": _selectedConditions.contains("Hypertension") ? 1 : 0,
          "Heart_Disease":
          _selectedConditions.contains("Heart Disease") ? 1 : 0,
          "Kidney_Disease":
          _selectedConditions.contains("Kidney Disease") ? 1 : 0,
        },
      };

      // 🧭 Hybrid navigation — works with both GoRouter & normal MaterialApp
      try {
        final router = GoRouter.of(context);
        router.pushNamed('mealSuggestion', extra: extras);
      } catch (_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MealSuggestionScreen(
              predictedCalories: extras["predictedCalories"],
              suggestedMeals:
              Map<String, dynamic>.from(extras["suggestedMeals"] ?? {}),
              conditions: List<String>.from(extras["conditions"] ?? []),
              profile: Map<String, dynamic>.from(extras["profile"] ?? {}),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: cs.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter Your Basic Information",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Height & Weight
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: Icon(Icons.height, color: cs.primary),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter height';
                        if (double.tryParse(v) == null) return 'Invalid number';
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
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter weight';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Activity Level
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: InputDecoration(
                  labelText: 'Activity Level',
                  prefixIcon: Icon(Icons.fitness_center, color: cs.primary),
                  border: const OutlineInputBorder(),
                ),
                items: _activityLevels
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedActivityLevel = value!),
              ),
              const SizedBox(height: 16),

              // Dietary Preference
              DropdownButtonFormField<String>(
                value: _selectedDietaryPreference,
                decoration: InputDecoration(
                  labelText: 'Dietary Preference',
                  prefixIcon: Icon(Icons.restaurant_menu, color: cs.primary),
                  border: const OutlineInputBorder(),
                ),
                items: _dietaryPreferences
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDietaryPreference = value!),
              ),
              const SizedBox(height: 16),

              // Budget Preference
              DropdownButtonFormField<String>(
                value: _selectedBudget,
                decoration: InputDecoration(
                  labelText: 'Budget Preference',
                  prefixIcon: Icon(Icons.money, color: cs.primary),
                  border: const OutlineInputBorder(),
                ),
                items: _budgetPreferences
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBudget = value!),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.fastfood),
                  label: const Text(
                    "Suggest Meal Plan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _suggestMealPlan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
