// lib/services/rating_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RatingService {
  RatingService({required this.baseUrl});
  final String baseUrl; // e.g. "http://192.168.1.78:8000" (no trailing slash)

  static const _uidKey = 'fitgen_user_id';
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String> userId() async {
    await _init();
    final exist = _prefs!.getString(_uidKey);
    if (exist != null && exist.isNotEmpty) return exist;
    final id = const Uuid().v4();
    await _prefs!.setString(_uidKey, id);
    return id;
  }

  String _yyyyMmDd([DateTime? d]) {
    final x = d ?? DateTime.now();
    final mm = x.month.toString().padLeft(2, '0');
    final dd = x.day.toString().padLeft(2, '0');
    return '${x.year}-$mm-$dd';
  }

  Future<Map<String, double>> getRatingsForDate({DateTime? date}) async {
    final uid = await userId();
    final day = _yyyyMmDd(date);

    final uri = Uri.parse('$baseUrl/ratings')
        .replace(queryParameters: {'userId': uid, 'date': day});

    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) return {};

    final decoded = json.decode(res.body) as Map<String, dynamic>;
    final map = (decoded['ratings'] as Map?)?.cast<String, dynamic>() ?? {};
    final out = <String, double>{};
    map.forEach((k, v) {
      if (v is num) {
        out[k] = v.toDouble();
      } else if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) out[k] = parsed;
      }
    });
    return out;
  }

  Future<void> setRating({
    required String mealKey,
    required double rating,
    DateTime? date,
  }) async {
    final uid = await userId();
    final day = _yyyyMmDd(date);

    final body = json.encode({
      'userId': uid,
      'mealKey': mealKey,
      'rating': rating,
      'date': day,
    });

    final res = await http.post(
      Uri.parse('$baseUrl/ratings'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to save rating: ${res.statusCode} ${res.body}');
    }

  }
}
