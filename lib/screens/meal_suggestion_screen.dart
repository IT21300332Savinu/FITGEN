import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/meal_detail_screen.dart';
import '../services/meal_suggestions_service.dart';

class MealSuggestionScreen extends StatefulWidget {
  @override
  State<MealSuggestionScreen> createState() => _MealSuggestionScreenState();
}

class _MealSuggestionScreenState extends State<MealSuggestionScreen> {
  late double predictedCalories;
  late Map<String, Map<String, dynamic>> suggestedMeals;

  List<String>? _conditionsArg;
  Map<String, dynamic>? _profileArg;

  final Map<String, Map<String, dynamic>> staticMealData = {
    "Breakfast": {
      "title": "",
      "description": "Rich in protein and antioxidants",
      "calories": 320,
      "icon": Icons.free_breakfast,
      "color": const Color(0xFFF8BBD0),
      "ingredients": ["Low-fat yogurt", "Blueberries", "Strawberries", "Honey"],
      "alternatives": {
        "Low-fat yogurt": ["Greek yogurt", "Plant-based yogurt (almond, soy)"],
        "Blueberries": ["Raspberries", "Blackberries"],
        "Strawberries": ["Kiwi", "Mango cubes"],
        "Honey": ["Agave syrup", "Maple syrup"],
      },
    },
    "Lunch": {
      "title": "",
      "description": "High fiber and plant protein",
      "calories": 580,
      "icon": Icons.rice_bowl,
      "color": const Color(0xFFC8E6C9),
      "ingredients": [
        "Brown rice",
        "Spinach",
        "Coconut milk",
        "Onion",
        "Garlic",
        "Curry spices (turmeric, cumin, coriander)",
      ],
      "alternatives": {
        "Brown rice": ["Quinoa", "Red rice"],
        "Spinach": ["Kale", "Moringa leaves"],
        "Coconut milk": ["Low-fat milk", "Soy cream"],
        "Onion": ["Leeks", "Shallots"],
        "Garlic": ["Ginger", "Asafoetida"],
        "Curry spices (turmeric, cumin, coriander)": [
          "Garam masala",
          "Italian herb mix",
        ],
      },
    },
    "Dinner": {
      "title": "",
      "description": "Light and nutritious evening meal",
      "calories": 420,
      "icon": Icons.restaurant,
      "color": const Color(0xFFBBDEFB),
      "ingredients": [
        "Vegetable broth",
        "Carrots",
        "Celery",
        "Onion",
        "Whole grain bread",
      ],
      "alternatives": {
        "Vegetable broth": ["Chicken broth", "Miso broth"],
        "Carrots": ["Sweet potatoes", "Pumpkin"],
        "Celery": ["Zucchini", "Green beans"],
        "Onion": ["Chives", "Fennel"],
        "Whole grain bread": ["Multigrain crackers", "Gluten-free toast"],
      },
    },
    "Snack": {
      "title": "",
      "description": "Perfect balance of fiber and protein",
      "calories": 220,
      "icon": Icons.local_cafe,
      "color": const Color(0xFFFFE0B2),
      "ingredients": ["Apple", "Peanut butter"],
      "alternatives": {
        "Apple": ["Pear", "Banana"],
        "Peanut butter": ["Almond butter", "Sunflower seed butter"],
      },
    },
  };

  Map<String, double> mealRatings = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null) return;

    _conditionsArg = (args["conditions"] as List?)?.cast<String>();
    _profileArg = args["profile"] as Map<String, dynamic>?;

    predictedCalories = (args["calories"] as num).toDouble();
    final Map<String, dynamic> mealMap = Map<String, dynamic>.from(args["meals"]);

    String _titleFor(String prettyKey) {
      final k1 = "$prettyKey Suggestion";
      if (mealMap.containsKey(k1)) return mealMap[k1]?.toString() ?? "No title";
      final k2 = prettyKey.toLowerCase();
      if (mealMap.containsKey(k2)) return mealMap[k2]?.toString() ?? "No title";
      final k3 = prettyKey[0].toLowerCase() + prettyKey.substring(1);
      if (mealMap.containsKey(k3)) return mealMap[k3]?.toString() ?? "No title";
      return "No title";
    }

    suggestedMeals = staticMealData.map((mealType, data) {
      return MapEntry(mealType, {...data, "title": _titleFor(mealType)});
    });

    // defaults
    for (var key in suggestedMeals.keys) {
      mealRatings[key] = 3.0;
    }

    // load saved ratings after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final api = ApiDio();
      final saved = await api.getRatingsForDate(date: DateTime.now());
      if (!mounted) return;
      setState(() {
        for (final entry in saved.entries) {
          if (suggestedMeals.containsKey(entry.key)) {
            mealRatings[entry.key] = entry.value;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Use global AppBarTheme (orange bg, white fg, centered)
        title: Text(
          "Your Meal Suggestions",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCalorieCard(context),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/custom-meal-plan-list'),
                  icon: const Icon(Icons.library_books),
                  label: const Text("My Custom Plans"),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Today's Meal Suggestions",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface, // THEME
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildMealsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // THEME: use primary → secondary gradient from theme
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.bubble_chart,
              size: 100,
              color: cs.onPrimary.withOpacity(0.08), // THEME
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Calorie Target",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: cs.onPrimary.withOpacity(0.95), // THEME
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      predictedCalories.toStringAsFixed(0),
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimary, // THEME
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "kcal",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs.onPrimary.withOpacity(0.95), // THEME
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final outline = theme.colorScheme.outlineVariant.withOpacity(0.25);

    double _ratingFor(String key) => mealRatings[key] ?? 3.0;

    return ListView.builder(
      itemCount: suggestedMeals.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        String mealKey = suggestedMeals.keys.elementAt(index);
        Map<String, dynamic> meal = suggestedMeals[mealKey]!;
        final Color accent = (meal["color"] as Color?) ?? cs.primaryContainer;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  mealType: mealKey,
                  mealData: meal,
                  predictedCalories: predictedCalories,
                  conditions: _conditionsArg,
                  profile: _profileArg,
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            // Uses global CardTheme (white bg, rounded, elevation)
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.25), // soft tint
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.45)),
                    ),
                    child: Icon(meal["icon"], color: cs.primary, size: 26), // THEME accent icon
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // small label row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mealKey,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: cs.primary, // THEME
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${meal["title"]}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface, // THEME
                          ),
                        ),
                        const SizedBox(height: 6),
                        // ⭐ Ratings
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: _ratingFor(mealKey),
                              minRating: 1,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 22,
                              unratedColor: outline, // THEME
                              itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                              onRatingUpdate: (value) async {
                                final old = _ratingFor(mealKey);
                                setState(() => mealRatings[mealKey] = value);
                                try {
                                  final api = ApiDio();
                                  await api.setRating(
                                    mealType: mealKey,
                                    rating: value,
                                    date: DateTime.now(),
                                    recipe: meal["title"]?.toString(),
                                    planKind: "ai",
                                  );
                                } catch (_) {
                                  // revert on failure if you want
                                  setState(() => mealRatings[mealKey] = old);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _ratingFor(mealKey).toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: cs.onSurface.withOpacity(0.8), // THEME
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
