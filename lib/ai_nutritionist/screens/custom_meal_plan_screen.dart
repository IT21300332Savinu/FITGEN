import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/meal_suggestions_service.dart' as svc;

class CustomMealPlanScreen extends StatefulWidget {
  const CustomMealPlanScreen({
    super.key,
    this.predictedCalories,
    this.conditions,
    this.profile,
    this.mode,
    this.plan,
  });

  final double? predictedCalories;
  final List<String>? conditions;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? plan;
  final String? mode;

  @override
  State<CustomMealPlanScreen> createState() => _CustomMealPlanScreenState();
}

class _CustomMealPlanScreenState extends State<CustomMealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _predictedCaloriesArg;
  Map<String, dynamic>? _profileArg;
  List<String>? _conditionsArg;

  // One editor per meal type
  final _breakfast = _MealEditor();
  final _lunch     = _MealEditor();
  final _dinner    = _MealEditor();
  final _snack     = _MealEditor();

  final _noteCtrl  = TextEditingController();

  bool _saving = false;
  String? _editingPlanId;

  @override
  void dispose() {
    _breakfast.dispose();
    _lunch.dispose();
    _dinner.dispose();
    _snack.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int _toInt(dynamic v) {
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  @override
  void initState() {
    super.initState();

    // Seed from constructor (for create/direct open)
    _predictedCaloriesArg = widget.predictedCalories;
    _profileArg    = widget.profile == null ? null : Map<String, dynamic>.from(widget.profile!);
    _conditionsArg = widget.conditions == null ? null : List<String>.from(widget.conditions!);

    // If edit mode, derive from the passed plan
    if (widget.mode == 'edit' && widget.plan != null) {
      final plan = Map<String, dynamic>.from(widget.plan!);
      _editingPlanId = plan["id"] as String?;

      _predictedCaloriesArg ??=
          (plan["predicted_calories"] as num?)?.toDouble();

      final note = (plan["note"] ?? "").toString();
      if (note.isNotEmpty) _noteCtrl.text = note;

      final meals = Map<String, dynamic>.from(plan["meals"] ?? {});
      _prefillMealEditor(_breakfast, meals["breakfast"]);
      _prefillMealEditor(_lunch,     meals["lunch"]);
      _prefillMealEditor(_dinner,    meals["dinner"]);
      _prefillMealEditor(_snack,     meals["snack"]);

      // If profile/conditions weren’t provided, derive from plan.profile (space keys)
      final pSpace = Map<String, dynamic>.from(plan["profile"] ?? {});
      if (_profileArg == null && pSpace.isNotEmpty) {
        _profileArg = <String, int>{
          'Diabetes'      : _toInt(pSpace['Diabetes']),
          'Hypertension'  : _toInt(pSpace['Hypertension']),
          'Heart_Disease' : _toInt(pSpace['Heart Disease']),
          'Kidney_Disease': _toInt(pSpace['Kidney Disease']),
        };
      }
      if (_conditionsArg == null && pSpace.isNotEmpty) {
        final conds = <String>[];
        void addIf(String k){ if (_toInt(pSpace[k]) == 1) conds.add(k); }
        addIf('Diabetes'); addIf('Hypertension'); addIf('Heart Disease'); addIf('Kidney Disease');
        _conditionsArg = conds;
      }
    }
  }

  void _prefillMealEditor(_MealEditor editor, dynamic block) {
    if (block == null) return;
    final map = Map<String, dynamic>.from(block as Map);
    final recipe = (map["recipe"] ?? "").toString();
    editor.recipeCtrl.text = recipe;

    final rows = List<Map<String, dynamic>>.from(
      map["ingredients_with_alternatives"] ?? const [],
    );
    for (final row in rows) {
      final r = _IngredientRow();
      r.ingredientCtrl.text = (row["ingredient"] ?? "").toString();

      final alts = List<String>.from(row["alternatives"] ?? const []);
      for (final a in alts) {
        final c = TextEditingController(text: a);
        r.altsCtrls.add(c);
      }
      editor.ingredients.add(r);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final api = svc.ApiDio();
    final cs = Theme.of(context).colorScheme;

    // 1) Validate first
    final validation = await api.validateCustomMealPlan(
      breakfast: _breakfast.toNullableDto(),
      lunch: _lunch.toNullableDto(),
      dinner: _dinner.toNullableDto(),
      snack: _snack.toNullableDto(),
      profile: _profileArg,
      conditions: _conditionsArg,
    );

    if (validation != null && (validation["warnings"] as List).isNotEmpty) {
      final proceed = await _showValidationDialog(context, validation);
      if (proceed != true) return; // user chose to edit
    }

    setState(() => _saving = true);
    final isEdit = _editingPlanId != null;

    final ok = isEdit
        ? await api.updateCustomMealPlan(
      id: _editingPlanId!,
      breakfast: _breakfast.toNullableDto(),
      lunch: _lunch.toNullableDto(),
      dinner: _dinner.toNullableDto(),
      snack: _snack.toNullableDto(),
      predictedCalories: _predictedCaloriesArg,
      profile: _profileArg,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    )
        : await api.submitCustomMealPlan(
      breakfast: _breakfast.toNullableDto(),
      lunch: _lunch.toNullableDto(),
      dinner: _dinner.toNullableDto(),
      snack: _snack.toNullableDto(),
      predictedCalories: _predictedCaloriesArg,
      profile: _profileArg,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? "Plan updated!" : "Plan saved!"),
          backgroundColor: cs.primary,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to save"),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  Future<bool?> _showValidationDialog(
      BuildContext context,
      Map<String, dynamic> validation,
      ) {
    final cs = Theme.of(context).colorScheme;
    final warnings = List<Map<String, dynamic>>.from(validation["warnings"] ?? []);
    Color _severityColor(String s) {
      switch (s) {
        case "high":
          return cs.error;
        case "moderate":
          return cs.secondary;
        default:
          return cs.tertiary;
      }
    }

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Heads up", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: warnings.map((w) {
              final meal = w["meal_type"];
              final disease = w["disease"];
              final severity = (w["severity"] ?? "info").toString();
              final reasons = List<String>.from(w["reasons"] ?? []);
              final suggestions = List<String>.from(w["suggestions"] ?? []);
              final color = _severityColor(severity);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.warning_amber_rounded, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "$meal • $disease • $severity".toUpperCase(),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ]),
                    if (reasons.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text("Why:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ...reasons.map((r) => Text("• $r", style: GoogleFonts.poppins(color: cs.onSurface))),
                    ],
                    if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text("Suggestions:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: cs.onSurface)),
                      ...suggestions.map((s) => Text("• $s", style: GoogleFonts.poppins(color: cs.onSurface))),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Edit"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Save anyway"),
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
          _editingPlanId == null ? "Build Your Meal Plan" : "Edit Meal Plan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MealEditorCard(
              title: "Breakfast",
              editor: _breakfast,
              color: const Color(0xFFF8BBD0),
            ),
            const SizedBox(height: 12),
            _MealEditorCard(
              title: "Lunch",
              editor: _lunch,
              color: const Color(0xFFC8E6C9),
            ),
            const SizedBox(height: 12),
            _MealEditorCard(
              title: "Dinner",
              editor: _dinner,
              color: const Color(0xFFBBDEFB),
            ),
            const SizedBox(height: 12),
            _MealEditorCard(
              title: "Snack",
              editor: _snack,
              color: const Color(0xFFFFE0B2),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Optional note (diet/cuisine/spice level, etc.)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(_editingPlanId == null ? Icons.save : Icons.check),
              label: Text(_editingPlanId == null ? "Save Custom Meal Plan" : "Update Plan"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Per-meal editor state
class _MealEditor {
  final recipeCtrl = TextEditingController();
  final ingredients = <_IngredientRow>[]; // each with alternatives list

  void addIngredient() => ingredients.add(_IngredientRow());
  void removeIngredient(int i) => ingredients.removeAt(i);

  /// Build a MealBlockDto OR return null if this meal section is empty.
  svc.MealBlockDto? toNullableDto() {
    final recipe = recipeCtrl.text.trim();

    final items = ingredients
        .map((row) => svc.IngredientAltDto(
      ingredient: row.ingredientCtrl.text.trim(),
      alternatives: row.altsCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    ))
    // drop fully empty ingredient rows
        .where((e) => e.ingredient.isNotEmpty || e.alternatives.isNotEmpty)
        .toList();

    if (recipe.isEmpty && items.isEmpty) return null;

    return svc.MealBlockDto(
      recipe: recipe,
      ingredientsWithAlternatives: items,
    );
  }

  void dispose() {
    recipeCtrl.dispose();
    for (final r in ingredients) {
      r.dispose();
    }
  }
}

class _IngredientRow {
  final ingredientCtrl = TextEditingController();
  final altsCtrls = <TextEditingController>[];

  void addAlternative() => altsCtrls.add(TextEditingController());
  void removeAlternative(int i) => altsCtrls.removeAt(i);

  void dispose() {
    ingredientCtrl.dispose();
    for (final c in altsCtrls) {
      c.dispose();
    }
  }
}

/// UI card for a meal
class _MealEditorCard extends StatefulWidget {
  final String title;
  final _MealEditor editor;
  final Color color;
  const _MealEditorCard({
    required this.title,
    required this.editor,
    required this.color,
  });

  @override
  State<_MealEditorCard> createState() => _MealEditorCardState();
}

class _MealEditorCardState extends State<_MealEditorCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      // uses global CardTheme
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.color.withOpacity(0.35)),
                ),
                child: Icon(Icons.restaurant_menu, color: widget.color),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.editor.recipeCtrl,
              decoration: const InputDecoration(
                labelText: "Meal (recipe) name",
                hintText: "e.g., Grilled Chicken & Quinoa",
                border: OutlineInputBorder(),
              ),
              validator: (v) => null, // allow empty section
            ),
            const SizedBox(height: 12),

            // Ingredients header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ingredients & Alternatives",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => widget.editor.addIngredient()),
                  icon: const Icon(Icons.add),
                  label: const Text("Add ingredient"),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (widget.editor.ingredients.isEmpty)
              Text(
                "No ingredients added yet.",
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),

            ...List.generate(widget.editor.ingredients.length, (i) {
              final row = widget.editor.ingredients[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IngredientEditorRow(
                  color: widget.color,
                  row: row,
                  onRemove: () => setState(() => widget.editor.removeIngredient(i)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IngredientEditorRow extends StatefulWidget {
  final _IngredientRow row;
  final VoidCallback onRemove;
  final Color color;
  const _IngredientEditorRow({
    required this.row,
    required this.onRemove,
    required this.color,
  });

  @override
  State<_IngredientEditorRow> createState() => _IngredientEditorRowState();
}

class _IngredientEditorRowState extends State<_IngredientEditorRow> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceVariant.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: widget.row.ingredientCtrl,
                  decoration: const InputDecoration(
                    labelText: "Ingredient",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: "Remove ingredient",
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Alternatives",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => widget.row.addAlternative()),
                  icon: const Icon(Icons.add),
                  label: const Text("Add alternative"),
                ),
              ],
            ),
            ...List.generate(widget.row.altsCtrls.length, (j) {
              final ctrl = widget.row.altsCtrls[j];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ctrl,
                        decoration: const InputDecoration(
                          labelText: "Alternative",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: "Remove",
                      onPressed: () => setState(() => widget.row.removeAlternative(j)),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              );
            }),
            if (widget.row.altsCtrls.isEmpty)
              Text(
                "No alternatives yet.",
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* DTOs used by your ApiDio extensions */
class IngredientAltDto {
  final String ingredient;
  final List<String> alternatives;
  IngredientAltDto({required this.ingredient, this.alternatives = const []});
  Map<String, dynamic> toJson() => {
    "ingredient": ingredient,
    "alternatives": alternatives,
  };
}

class MealBlockDto {
  final String recipe;
  final List<IngredientAltDto> ingredientsWithAlternatives;
  MealBlockDto({required this.recipe, this.ingredientsWithAlternatives = const []});
  Map<String, dynamic> toJson() => {
    "recipe": recipe,
    "ingredients_with_alternatives":
    ingredientsWithAlternatives.map((e) => e.toJson()).toList(),
  };
}
