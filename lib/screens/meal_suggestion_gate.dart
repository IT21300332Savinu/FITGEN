import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fitgen_socialbridge/flutter_flow/flutter_flow_util.dart';
import '../services/meal_suggestions_service.dart';
import 'profile_screen_meal.dart';
import 'meal_suggestion_screen.dart';

class MealSuggestionGate extends StatefulWidget {
  const MealSuggestionGate({super.key});

  @override
  State<MealSuggestionGate> createState() => _MealSuggestionGateState();
}

enum _GatePhase { fetching, preparing, idle }

class _MealSuggestionGateState extends State<MealSuggestionGate> {
  _GatePhase _phase = _GatePhase.idle;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (_busy) return;
    _busy = true;

    setState(() => _phase = _GatePhase.fetching); // 1) Fetching your profile...
    await Future.delayed(const Duration(seconds: 3));
    try {
      final api = ApiDio();
      // TODO: swap to currentUserUid if available
      final result = await api.suggestMeal("sKr1Ay7QOIcys7kzE0lJYkiNbyG3");

      if (result == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No profile found. Please complete your profile.')),
        );
        // Small pause to let the user read, then go to profile setup
        await Future.delayed(const Duration(milliseconds: 3000));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        return;
      }

      // 2) Preparing your meal suggestions...
      if (!mounted) return;
      setState(() => _phase = _GatePhase.preparing);

      // ===== derive from backend profile =====
      final p = Map<String, dynamic>.from(result['profile'] ?? {});

      int toInt(dynamic v) {
        if (v is bool) return v ? 1 : 0;
        if (v is num) return v.toInt();
        return int.tryParse(v?.toString() ?? '0') ?? 0;
      }

      // conditions (space keys)
      final conditions = <String>[];
      void addIf(String key, String label) {
        if (toInt(p[key]) == 1) conditions.add(label);
      }
      addIf('Diabetes', 'Diabetes');
      addIf('Hypertension', 'Hypertension');
      addIf('Heart Disease', 'Heart Disease');
      addIf('Kidney Disease', 'Kidney Disease');
      // addIf('Acne', 'Acne'); addIf('Weight Gain', 'Weight Gain'); addIf('Weight Loss', 'Weight Loss');

      // mini disease map with underscore keys (what your screen expects)
      final diseaseProfile = <String, int>{
        'Diabetes'      : toInt(p['Diabetes']),
        'Hypertension'  : toInt(p['Hypertension']),
        'Heart_Disease' : toInt(p['Heart Disease']),
        'Kidney_Disease': toInt(p['Kidney Disease']),
      };

      // brief delay so the user sees the second message
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      context.pushNamedAuth(
        'mealSuggestion',
        mounted,
        extra: {
          "calories": (result["predicted_calories"] as num?)?.toDouble() ?? 0.0,
          "meals": Map<String, dynamic>.from(result["suggested_meals"] ?? {}),
          "conditions": conditions,
          "profile": diseaseProfile,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t load meal suggestions: $e')),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _boot() => _start(); // keep your Retry button hook

  @override
  Widget build(BuildContext context) {
    String message;
    switch (_phase) {
      case _GatePhase.fetching:
        message = 'Fetching your profile...';
        break;
      case _GatePhase.preparing:
        message = 'Preparing your meal suggestions...';
        break;
      case _GatePhase.idle:
      default:
        message = 'Starting...';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nutritionist')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                message,
                key: ValueKey(message),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _boot,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
