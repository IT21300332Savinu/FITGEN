import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/meal_suggestions_service.dart';
import 'custom_meal_plan_screen.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealType;
  final Map<String, dynamic> mealData;
  final double? predictedCalories;
  final List<String>? conditions;
  final Map<String, dynamic>? profile;

  const MealDetailScreen({
    Key? key,
    required this.mealType,
    required this.mealData,
    this.predictedCalories,
    this.conditions,
    this.profile,
  }) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Map<String, String> selectedIngredients;
  bool isEditing = false;

  Map<String, List<String>> ingredientAlternatives = {};
  List<String> ingredientList = [];
  bool isLoading = true;

  final _customRecipeCtrl = TextEditingController();
  final _customNoteCtrl = TextEditingController();

  @override
  void dispose() {
    _customRecipeCtrl.dispose();
    _customNoteCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedIngredients = {}; // make sure it's initialized

    // Defer API call until after first frame so Theme.of(context) is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title = (widget.mealData["title"] ?? "").toString();
      if (title.isNotEmpty) {
        fetchIngredientsWithAlternatives(title);
      } else {
        setState(() => isLoading = false);
      }
    });
  }

  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    fetchIngredientsWithAlternatives(widget.mealData["title"]);
  }

  Future<void> _submitCustomPreference() async {
    final cs = Theme.of(context).colorScheme;

    final text = _customRecipeCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please type what you’d like."),
          backgroundColor: cs.error,
        ),
      );
      return;
    }

    // ingredient -> chosen alt (only if changed)
    final Map<String, String> changed = {};
    for (final ing in ingredientList) {
      final sel = selectedIngredients[ing]!;
      if (sel != ing) changed[ing] = sel;
    }

    final ok = await ApiDio().submitCustomPreference(
      mealType: widget.mealType,
      preferredRecipe: text,
      note: _customNoteCtrl.text.trim().isEmpty ? null : _customNoteCtrl.text.trim(),
      selectedAlternatives: changed.isEmpty ? null : changed,
      predictedCalories: widget.predictedCalories,
      profile: widget.profile,
    );

    if (!mounted) return;
    if (ok) {
      _customRecipeCtrl.clear();
      _customNoteCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Thanks! Your preference was saved."),
          backgroundColor: cs.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Couldn’t save preference. Try again."),
          backgroundColor: cs.error,
        ),
      );
    }
  }

  Future<void> fetchIngredientsWithAlternatives(String recipeName) async {
    try {
      final response = await ApiDio().getRecipeAlternatives(recipeName);
      if (response != null && response.containsKey("ingredients_with_alternatives")) {
        final List<dynamic> list = response["ingredients_with_alternatives"];
        if (!mounted) return;
        setState(() {
          ingredientList = list.map((e) => e["ingredient"] as String).toList();
          ingredientAlternatives = {
            for (final e in list) e["ingredient"] as String: List<String>.from(e["alternatives"])
          };
          selectedIngredients = { for (final ing in ingredientList) ing: ing };
          isLoading = false;
        });
      } else {
        throw Exception("No data received");
      }
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme; // safe now
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to load alternatives."),
          backgroundColor: cs.error,
        ),
      );
      setState(() => isLoading = false);
    }
  }


  void _toggleEditing() => setState(() => isEditing = !isEditing);

  void _selectAlternative(String originalIngredient, String alternative) {
    setState(() => selectedIngredients[originalIngredient] = alternative);
  }

  void _resetToOriginal(String originalIngredient) {
    setState(() => selectedIngredients[originalIngredient] = originalIngredient);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ingredients = ingredientList;
    final alternatives = ingredientAlternatives;
    final Color mealColor = widget.mealData["color"] ?? cs.primaryContainer;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("${widget.mealType} Details")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.mealType} Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditing,
            tooltip: isEditing ? "Save changes" : "Edit ingredients",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealHeader(context, mealColor),
            const SizedBox(height: 24),

            // Ingredients & Alternatives
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ingredients & Alternatives",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (isEditing)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        for (final ing in ingredients) {
                          selectedIngredients[ing] = ing;
                        }
                      });
                    },
                    icon: const Icon(Icons.restart_alt, size: 18),
                    label: const Text("Reset All"),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            ...ingredients.map((ingredient) {
              final altOptions = alternatives[ingredient] ?? [];
              final isSelected = selectedIngredients[ingredient] != ingredient;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Column(
                    children: [
                      // Ingredient header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? mealColor.withOpacity(0.12) : cs.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.swap_horiz : Icons.check_circle_outline,
                              color: isSelected ? mealColor : cs.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  if (isSelected)
                                    Row(
                                      children: [
                                        Text(
                                          "Using: ",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: cs.onSurface.withOpacity(0.65),
                                          ),
                                        ),
                                        Text(
                                          selectedIngredients[ingredient]!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: mealColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected && isEditing)
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                onPressed: () => _resetToOriginal(ingredient),
                                tooltip: "Reset to original",
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                          ],
                        ),
                      ),

                      // Alternatives
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (altOptions.isNotEmpty) ...[
                              Text(
                                isEditing ? "Select an alternative:" : "Alternatives:",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: altOptions.map((alt) {
                                        final isActive = selectedIngredients[ingredient] == alt;
                                        return isEditing
                                            ? ChoiceChip(
                                          label: Text(alt),
                                          selected: isActive,
                                          onSelected: (selected) {
                                            if (selected) _selectAlternative(ingredient, alt);
                                          },
                                          backgroundColor: cs.surface,
                                          selectedColor: cs.primary.withOpacity(0.12),
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: isActive ? cs.primary : cs.onSurface,
                                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        )
                                            : Chip(
                                          label: Text(alt),
                                          backgroundColor: isActive
                                              ? cs.primary.withOpacity(0.12)
                                              : cs.secondary.withOpacity(0.10),
                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: isActive ? cs.primary : cs.onSurface,
                                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Text(
                                "No alternatives available for this ingredient.",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: cs.onSurface.withOpacity(0.55),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // “Don’t like these?” card
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.feedback, color: mealColor),
                        const SizedBox(width: 8),
                        Text(
                          "Don’t like these?",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tell us what you’d like and we’ll learn from it.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customRecipeCtrl,
                      decoration: const InputDecoration(
                        labelText: "Type your preferred meal (e.g., “Caesar salad”)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customNoteCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Optional note (diet, cuisine, spice level, etc.)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: _submitCustomPreference,
                        icon: const Icon(Icons.send),
                        label: const Text("Submit preference"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            height: 24,
                            color: cs.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "or",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            height: 24,
                            color: cs.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CustomMealPlanScreen(
                                predictedCalories: widget.predictedCalories!.toDouble(),
                                conditions:  widget.conditions ?? const <String>[],
                                profile: widget.profile ??
                                    {
                                      for (final c in (widget.conditions ?? const <String>[])) c: 1
                                    },
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.tune),
                        label: const Text("Build My Own Plan"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save/Back Button
            if (isEditing)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => isEditing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Changes saved successfully!"),
                        backgroundColor: cs.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    "Back to Meal Plan",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMealHeader(BuildContext context, Color mealColor) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mealColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mealColor.withOpacity(0.35)),
              ),
              child: Icon(
                widget.mealData["icon"],
                color: mealColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mealData["title"],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.mealData["description"],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
