import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  String _displayName = 'Sippy Fan';
  String _preferredType = 'Any'; // Any, Alcoholic, Non-alcoholic
  int _maxIngredients = 10; // default for filters
  bool _isDarkMode = false;

  String get displayName => _displayName;
  String get preferredType => _preferredType;
  int get maxIngredients => _maxIngredients;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _displayName = _prefs.getString('settings_display_name') ?? _displayName;
    _preferredType = _prefs.getString('settings_preferred_type') ?? _preferredType;
    _maxIngredients = _prefs.getInt('settings_max_ingredients') ?? _maxIngredients;
    _isDarkMode = _prefs.getBool('settings_dark_mode') ?? _isDarkMode;
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    _displayName = name.trim().isEmpty ? 'Sippy Fan' : name.trim();
    await _prefs.setString('settings_display_name', _displayName);
    notifyListeners();
  }

  Future<void> setPreferredType(String type) async {
    _preferredType = type;
    await _prefs.setString('settings_preferred_type', _preferredType);
    notifyListeners();
  }

  Future<void> setMaxIngredients(int value) async {
    _maxIngredients = value.clamp(1, 15);
    await _prefs.setInt('settings_max_ingredients', _maxIngredients);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('settings_dark_mode', _isDarkMode);
    notifyListeners();
  }
}
