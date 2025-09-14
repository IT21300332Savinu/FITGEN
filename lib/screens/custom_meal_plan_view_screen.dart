import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomMealPlanViewScreen extends StatelessWidget {
  const CustomMealPlanViewScreen({
    super.key,
    required this.plan,
  });

  final Map<String, dynamic> plan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // use the plan from constructor
    final meals = Map<String, dynamic>.from(plan["meals"] ?? {});

    Widget mealCard(String label, Map<String, dynamic>? block, Color accent) {
      if (block == null) return const SizedBox.shrink();

      final recipe = (block["recipe"] ?? "").toString();
      final list = List<Map<String, dynamic>>.from(
        block["ingredients_with_alternatives"] ?? const [],
      );

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restaurant, color: accent),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              if (recipe.isNotEmpty)
                Text(
                  recipe,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              const SizedBox(height: 12),
              ...list.map((row) {
                final ing = (row["ingredient"] ?? "").toString();
                final alts = List<String>.from(row["alternatives"] ?? const []);
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ing.isNotEmpty)
                        Text(
                          ing,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      const SizedBox(height: 6),
                      if (alts.isEmpty)
                        Text(
                          "No alternatives",
                          style: GoogleFonts.poppins(
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: alts.map((a) {
                            return Chip(
                              label: Text(
                                a,
                                style: GoogleFonts.poppins(color: cs.onSurface),
                              ),
                              backgroundColor: cs.secondary.withOpacity(0.10),
                              side: BorderSide(
                                color: cs.outlineVariant.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Custom Plan Details",
          style: GoogleFonts.poppins(
            textStyle: theme.appBarTheme.titleTextStyle,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: theme.appBarTheme.centerTitle ?? true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if ((plan["note"] as String?)?.trim().isNotEmpty == true) ...[
            Text(
              "Note",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              plan["note"],
              style: GoogleFonts.poppins(color: cs.onSurface),
            ),
            const SizedBox(height: 16),
          ],
          mealCard("Breakfast", meals["breakfast"], const Color(0xFFF8BBD0)),
          mealCard("Lunch", meals["lunch"], const Color(0xFFC8E6C9)),
          mealCard("Dinner", meals["dinner"], const Color(0xFFBBDEFB)),
          mealCard("Snack", meals["snack"], const Color(0xFFFFE0B2)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
