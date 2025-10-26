import 'package:fitgen_socialbridge/screens/custom_meal_plan_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/meal_suggestions_service.dart';
import '../theme/app_theme.dart';
import 'custom_meal_plan_screen.dart';
import 'custom_plan_suggestion_screen.dart';

class CustomMealPlanListScreen extends StatefulWidget {
  const CustomMealPlanListScreen({super.key});

  @override
  State<CustomMealPlanListScreen> createState() =>
      _CustomMealPlanListScreenState();
}

class _CustomMealPlanListScreenState extends State<CustomMealPlanListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = ApiDio().getCustomMealPlans(limit: 50);
    });
  }

  Map<String, dynamic> _mealsMapForSuggestionScreen(Map<String, dynamic> plan) {
    final meals = Map<String, dynamic>.from(plan["meals"] ?? {});
    final out = <String, dynamic>{};
    if (meals["breakfast"]?["recipe"] != null)
      out["breakfast"] = meals["breakfast"]["recipe"];
    if (meals["lunch"]?["recipe"] != null)
      out["lunch"] = meals["lunch"]["recipe"];
    if (meals["dinner"]?["recipe"] != null)
      out["dinner"] = meals["dinner"]["recipe"];
    if (meals["snack"]?["recipe"] != null)
      out["snack"] = meals["snack"]["recipe"];
    return out;
  }

  Widget _mealChip(String label, Map? block, Color accent, ColorScheme cs) {
    if (block == null) return const SizedBox.shrink();
    final recipe = (block["recipe"] ?? "").toString();
    if (recipe.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            "$label: $recipe",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
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
        title: Text(
          "My Custom Plans",
          // Inherit AppBar text color from theme to keep it white on orange
          style: GoogleFonts.poppins(
            textStyle: theme.appBarTheme.titleTextStyle,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: theme.appBarTheme.centerTitle ?? true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                "Failed to load",
                style: GoogleFonts.poppins(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text(
                "No custom plans yet.",
                style: GoogleFonts.poppins(
                  color: cs.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final plan = items[i];
              final meals = Map<String, dynamic>.from(plan["meals"] ?? {});
              final ts = DateTime.fromMillisecondsSinceEpoch(
                (plan["ts_ms"] ?? 0) as int,
                isUtc: false,
              );
              final savedWhen = ts.toLocal().toString().split('.').first;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                // Uses your global CardTheme (white, elevation, rounded corners)
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Icon(Icons.event_note, color: cs.primary),
                          const SizedBox(width: 8),
                          Text(
                            "Saved: $savedWhen",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: "Delete",
                            onPressed: () async {
                              final ok = await ApiDio()
                                  .deleteCustomMealPlan(plan["id"]);
                              if (!mounted) return;
                              if (ok) {
                                _reload();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Plan deleted'),
                                    backgroundColor: cs.primary,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Delete failed'),
                                    backgroundColor: cs.error,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.delete_outline, color: cs.error),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Meal chips
                      Wrap(
                        children: [
                          _mealChip("Breakfast", meals["breakfast"],
                              const Color(0xFFF8BBD0), cs),
                          _mealChip("Lunch", meals["lunch"],
                              const Color(0xFFC8E6C9), cs),
                          _mealChip("Dinner", meals["dinner"],
                              const Color(0xFFBBDEFB), cs),
                          _mealChip("Snack", meals["snack"],
                              const Color(0xFFFFE0B2), cs),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Actions
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final changed = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomMealPlanScreen(
                                    mode: "edit",
                                    plan: Map<String, dynamic>.from(plan),
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              if (changed == true) _reload();
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomMealPlanViewScreen(
                                    plan: Map<String, dynamic>.from(plan),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text("View"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.primary,
                              side: BorderSide(color: cs.primary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Use this plan
                      ElevatedButton.icon(
                        onPressed: () async {
                          num? pc = plan["predicted_calories"];
                          double? calories = pc == null ? null : pc.toDouble();

                          if (calories == null || calories <= 0) {
                            calories = await showDialog<double>(
                              context: context,
                              builder: (ctx) {
                                final ctrl = TextEditingController();
                                return AlertDialog(
                                  title: const Text(
                                      "Enter your daily calorie target"),
                                  content: TextField(
                                    controller: ctrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: "e.g., 2000",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final v =
                                            double.tryParse(ctrl.text.trim());
                                        Navigator.pop(ctx, v);
                                      },
                                      child: const Text("Use"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (calories == null) return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CustomPlanSuggestionScreen(
                                plan: Map<String, dynamic>.from(plan),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Use this plan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          // keep the green success accent
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
