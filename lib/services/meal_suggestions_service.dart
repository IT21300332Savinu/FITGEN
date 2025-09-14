import 'dart:convert';
import 'package:dio/dio.dart';

final _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

class ApiDio {
  Future<Map<String, dynamic>?> suggestMeal(Map<String, dynamic> userProfile) async {
    try {
      final res = await _dio.post('/suggest-meal', data: jsonEncode(userProfile));
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print("suggestMeal error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRecipeAlternatives(String recipeName) async {
    try {
      final res = await _dio.post(
        '/get-recipe-alternatives',
        data: jsonEncode({"recipe": recipeName}),
      );
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print("getRecipeAlternatives error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getIngredients(String recipeName) async {
    try {
      final res = await _dio.post(
        '/get-ingredients',
        data: jsonEncode({"recipe": recipeName}),
      );
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print("getIngredients error: $e");
    }
    return null;
  }

  // add this method to ApiDio class
  Future<bool> submitCustomPreference({
    required String mealType,           // Breakfast/Lunch/Dinner/Snack
    required String preferredRecipe,    // free-text
    String? note,
    Map<String, String>? selectedAlternatives, // {ingredient: choice}
    double? predictedCalories,
    Map<String, dynamic>? profile,
  }) async {
    try {
      final body = {
        "meal_type": mealType,
        "preferred_recipe": preferredRecipe,
        "note": note,
        "selected_alternatives": selectedAlternatives,
        "predicted_calories": predictedCalories,
        "profile": profile,
      };
      final res = await _dio.post('/custom-preference', data: jsonEncode(body));
      return res.statusCode == 200;
    } catch (e) {
      print("submitCustomPreference error: $e");
      return false;
    }
  }

  Future<bool> setRating({
    required String mealType,        // "Breakfast" | "Lunch" | "Dinner" | "Snack"
    required double rating,          // 1.0 - 5.0
    DateTime? date,                  // optional; server will use "today" if missing
    String? recipe,                  // optional: meal title for context
    String? planKind,                // "ai" or "custom"
    String? planId,                  // if custom plan
  }) async {
    try {
      final body = {
        if (date != null) "date": date.toIso8601String().substring(0, 10),
        "meal_type": mealType,
        "rating": rating,
        if (recipe != null) "recipe": recipe,
        if (planKind != null) "plan_kind": planKind,
        if (planId != null) "plan_id": planId,
      };
      final res = await _dio.post('/ratings/set', data: jsonEncode(body));
      return res.statusCode == 200;
    } catch (e) {
      print("setRating error: $e");
      return false;
    }
  }

  Future<Map<String, double>> getRatingsForDate({required DateTime date}) async {
    try {
      final ds = date.toIso8601String().substring(0, 10); // "YYYY-MM-DD"
      final res = await _dio.get('/ratings/$ds');
      if (res.statusCode == 200) {
        final m = Map<String, dynamic>.from(res.data["ratings"] ?? {});
        return m.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (e) {
      print("getRatingsForDate error: $e");
    }
    return {};
  }

}

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
    "ingredients_with_alternatives": ingredientsWithAlternatives.map((e) => e.toJson()).toList(),
  };
}

extension _NullStrip on Map<String, dynamic> {
  Map<String, dynamic> stripNulls() {
    final m = <String, dynamic>{};
    for (final e in entries) {
      if (e.value != null) m[e.key] = e.value;
    }
    return m;
  }
}

extension ApiDioCustom on ApiDio {
  Future<bool> submitCustomMealPlan({
    MealBlockDto? breakfast,
    MealBlockDto? lunch,
    MealBlockDto? dinner,
    MealBlockDto? snack,
    double? predictedCalories,
    Map<String, dynamic>? profile,
    String? note,
  }) async {
    try {
      final body = {
        "breakfast": breakfast?.toJson(),
        "lunch": lunch?.toJson(),
        "dinner": dinner?.toJson(),
        "snack": snack?.toJson(),
        "predicted_calories": predictedCalories,
        "profile": profile,
        "note": note,
      }.stripNulls();

      final res = await _dio.post('/custom-meal-plan', data: jsonEncode(body));
      return res.statusCode == 200;
    } catch (e) {
      print("submitCustomMealPlan error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getLatestCustomMealPlan() async {
    try {
      final res = await _dio.get('/custom-meal-plan/latest');
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data ?? {});
    } catch (e) {
      print("getLatestCustomMealPlan error: $e");
    }
    return null;
  }
}

extension ApiDioCustomList on ApiDio {
  Future<List<Map<String, dynamic>>> getCustomMealPlans({int limit = 20}) async {
    try {
      final res = await _dio.get('/custom-meal-plans', queryParameters: {"limit": limit});
      if (res.statusCode == 200) {
        final list = (res.data?["items"] as List?) ?? [];
        return list.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      print("getCustomMealPlans error: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getCustomMealPlanById(String id) async {
    try {
      final res = await _dio.get('/custom-meal-plan/$id');
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data ?? {});
    } catch (e) {
      print("getCustomMealPlanById error: $e");
    }
    return null;
  }

  Future<bool> deleteCustomMealPlan(String id) async {
    try {
      final res = await _dio.delete('/custom-meal-plan/$id');
      return res.statusCode == 200;
    } catch (e) {
      print("deleteCustomMealPlan error: $e");
      return false;
    }
  }
}

extension ApiDioCustomUpdate on ApiDio {
  Future<bool> updateCustomMealPlan({
    required String id,
    MealBlockDto? breakfast,
    MealBlockDto? lunch,
    MealBlockDto? dinner,
    MealBlockDto? snack,
    double? predictedCalories,
    Map<String, dynamic>? profile,
    String? note,
  }) async {
    try {
      final body = {
        "breakfast": breakfast?.toJson(),
        "lunch": lunch?.toJson(),
        "dinner": dinner?.toJson(),
        "snack": snack?.toJson(),
        "predicted_calories": predictedCalories,
        "profile": profile,
        "note": note,
      }.stripNulls();

      final res = await _dio.put('/custom-meal-plan/$id', data: jsonEncode(body));
      return res.statusCode == 200;
    } catch (e) {
      print("updateCustomMealPlan error: $e");
      return false;
    }
  }
}

extension ApiDioValidation on ApiDio {
  Future<Map<String, dynamic>?> validateCustomMealPlan({
    MealBlockDto? breakfast,
    MealBlockDto? lunch,
    MealBlockDto? dinner,
    MealBlockDto? snack,
    Map<String, dynamic>? profile,
    List<String>? conditions, // optional; if null, backend will derive from profile
  }) async {
    try {
      final body = {
        "plan": {
          "breakfast": breakfast?.toJson(),
          "lunch": lunch?.toJson(),
          "dinner": dinner?.toJson(),
          "snack": snack?.toJson(),
          "profile": profile,
        },
        "conditions": conditions,
      };
      final res = await _dio.post('/validate-meal-plan', data: jsonEncode(body));
      if (res.statusCode == 200) return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print("validateCustomMealPlan error: $e");
    }
    return null;
  }
}
