import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPlanDetailScreen extends StatelessWidget {
  const CustomPlanDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String mealType = args["mealType"];
    final Map<String, dynamic> block = Map<String, dynamic>.from(args["block"]);
    final Color color = args["color"] as Color;
    final IconData icon = args["icon"] as IconData;
    final String desc = (args["desc"] ?? "") as String;

    final recipe = (block["recipe"] ?? "").toString();
    final List<Map<String, dynamic>> rows =
    List<Map<String, dynamic>>.from(block["ingredients_with_alternatives"] ?? const []);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "$mealType Details",
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
          _header(theme, color, icon, mealType, recipe, desc),
          const SizedBox(height: 16),
          Text(
            "Ingredients & Alternatives",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Text(
              "No ingredients provided.",
              style: GoogleFonts.poppins(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...rows.map((row) => _ingredientCard(theme, color, row)).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(
      ThemeData theme,
      Color color,
      IconData icon,
      String mealType,
      String recipe,
      String desc,
      ) {
    final cs = theme.colorScheme;

    return Card(
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.isEmpty ? "No recipe set" : recipe,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ingredientCard(ThemeData theme, Color accent, Map<String, dynamic> row) {
    final cs = theme.colorScheme;
    final ing = (row["ingredient"] ?? "").toString();
    final alts = List<String>.from(row["alternatives"] ?? const []);

    final hasAlts = alts.isNotEmpty;
    final iconColor = hasAlts ? accent : cs.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: theme.cardTheme.shape,
      elevation: theme.cardTheme.elevation == null ? 1 : theme.cardTheme.elevation,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                hasAlts ? Icons.swap_horiz : Icons.check_circle_outline,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ing.isEmpty ? "(Unnamed ingredient)" : ing,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            if (!hasAlts)
              Text(
                "No alternatives",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alts
                    .map(
                      (a) => Chip(
                    label: Text(
                      a,
                      style: GoogleFonts.poppins(
                        color: cs.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    backgroundColor: cs.primary.withOpacity(0.10),
                    shape: StadiumBorder(
                      side: BorderSide(color: cs.primary.withOpacity(0.25)),
                    ),
                  ),
                )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
