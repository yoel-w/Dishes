import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_color_scheme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService instance = ThemeService._();
  ThemeService._();

  AppColorScheme _scheme = AppColorScheme.orange;
  AppColorScheme get scheme => _scheme;

  double _textScale = 1.0;
  double get textScale => _textScale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('theme_id');
      if (id != null) {
        final match = AppColorScheme.all.where((s) => s.id == id).firstOrNull;
        if (match != null) _scheme = match;
      }
      _textScale = (prefs.getDouble('text_scale') ?? 1.0).clamp(0.9, 1.1);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setScheme(AppColorScheme scheme) async {
    if (_scheme.id == scheme.id) return;
    _scheme = scheme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_id', scheme.id);
    } catch (_) {}
  }

  Future<void> setTextScale(double scale) async {
    if (_textScale == scale) return;
    _textScale = scale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('text_scale', scale);
    } catch (_) {}
  }
}
