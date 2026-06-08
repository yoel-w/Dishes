import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dish.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService instance = FavoritesService._();
  FavoritesService._();

  final List<Dish> _favorites = [];
  List<Dish> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('favorites') ?? [];
      _favorites.clear();
      for (final s in raw) {
        try {
          _favorites.add(Dish.fromJson(jsonDecode(s)));
        } catch (_) {}
      }
      notifyListeners();
    } catch (_) {}
  }

  bool isFavorite(String id) => _favorites.any((d) => d.id == id);

  Future<void> toggle(Dish dish) async {
    if (isFavorite(dish.id)) {
      _favorites.removeWhere((d) => d.id == dish.id);
    } else {
      _favorites.add(dish);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'favorites',
        _favorites.map((d) => jsonEncode(d.toJson())).toList(),
      );
    } catch (_) {}
  }
}
