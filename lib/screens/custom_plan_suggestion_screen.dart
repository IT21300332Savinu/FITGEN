import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_plan_detail_screen.dart';

class CustomPlanSuggestionScreen extends StatefulWidget {
  const CustomPlanSuggestionScreen({
    super.key,
    required this.plan,
  });

  final Map<String, dynamic> plan;

  @override
  State<CustomPlanSuggestionScreen> createState() => _CustomPlanSuggestionScreenState();
}

class _CustomPlanSuggestionScreenState extends State<CustomPlanSuggestionScreen> {
  late final Map<String, dynamic> plan;   // incoming plan map
  late final Map<String, dynamic> meals;  // plan["meals"]
  double? predictedCalories;

  static const _mealCfg = {
    "Breakfast": {"icon": Icons.free_breakfast, "color": Color(0xFFF8BBD0), "desc": "Kickstart your day"},
    "Lunch":     {"icon": Icons.rice_bowl,      "color": Color(0xFFC8E6C9), "desc": "Midday energy"},
    "Dinner":    {"icon": Icons.restaurant,     "color": Color(0xFFBBDEFB), "desc": "Light & nourishing"},
    "Snack":     {"icon": Icons.local_cafe,     "color": Color(0xFFFFE0B2), "desc": "Smart bites"},
  };

  @override
  void initState() {
    super.initState();
    plan  = Map<String, dynamic>.from(widget.plan);
    meals = Map<String, dynamic>.from(plan["meals"] ?? {});
    final pc = plan["predicted_calories"];
    if (pc is num) predictedCalories = pc.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final sections = ["Breakfast", "Lunch", "Dinner", "Snack"];
    final present = sections.where((s) => meals[s.toLowerCase()] != null).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Your Custom Plan",
          style: GoogleFonts.poppins(
            textStyle: theme.appBarTheme.titleTextStyle,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: theme.appBarTheme.centerTitle ?? true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (predictedCalories != null) _calorieCard(theme),
            const SizedBox(height: 16),
            Text(
              "Today's Custom Selections",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: present.length,
                itemBuilder: (_, i) {
                  final label = present[i];
                  final block = Map<String, dynamic>.from(meals[label.toLowerCase()]);
                  final cfg   = _mealCfg[label]!;
                  final color = cfg["color"] as Color;
                  final icon  = cfg["icon"] as IconData;
                  final recipe = (block["recipe"] ?? "").toString();

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CustomPlanDetailScreen(
                            mealType: label,
                            block: block,
                            color: color,
                            icon: icon,
                            desc: cfg["desc"] as String? ?? '',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color.withOpacity(0.35)),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary)),
                                  const SizedBox(height: 6),
                                  Text(
                                    recipe.isEmpty ? "No recipe set" : recipe,
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(cfg["desc"] as String, style: GoogleFonts.poppins(fontSize: 12, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calorieCard(ThemeData theme) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cs.primary, cs.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daily Calorie Target", style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9))),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${predictedCalories!.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("kcal", style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
