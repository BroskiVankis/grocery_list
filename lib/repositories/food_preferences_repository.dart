import 'dart:convert';

import 'package:grocery_list/models/food_preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodPreferencesRepository {
  static const String _storageKey = 'food_preferences';

  Future<FoodPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return const FoodPreferences();
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return FoodPreferences.fromJson(decoded);
      }
      if (decoded is Map) {
        return FoodPreferences.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      return const FoodPreferences();
    }

    return const FoodPreferences();
  }

  Future<void> save(FoodPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(preferences.toJson());
    await prefs.setString(_storageKey, raw);
  }
}
