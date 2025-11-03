import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  String _displayName = 'Sippy Fan';
  String _preferredType = 'Any'; // Any, Alcoholic, Non-alcoholic
  int _maxIngredients = 10; // default for filters
  bool _isDarkMode = false;
  String? _profilePicturePath; // Path to selected profile picture
  bool? _isOver21; // null = not asked, true = yes, false = no
  String _unitSystem = 'us'; // 'us' or 'metric'
  bool _seenOnboarding = false;

  String get displayName => _displayName;
  String get preferredType => _preferredType;
  int get maxIngredients => _maxIngredients;
  bool get isDarkMode => _isDarkMode;
  String? get profilePicturePath => _profilePicturePath;
  bool? get isOver21 => _isOver21;
  bool get needsAgeVerification => _isOver21 == null;
  String get unitSystem => _unitSystem;
  bool get seenOnboarding => _seenOnboarding;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _displayName = _prefs.getString('settings_display_name') ?? _displayName;
    _preferredType = _prefs.getString('settings_preferred_type') ?? _preferredType;
    _maxIngredients = _prefs.getInt('settings_max_ingredients') ?? _maxIngredients;
    _isDarkMode = _prefs.getBool('settings_dark_mode') ?? _isDarkMode;
    _profilePicturePath = _prefs.getString('settings_profile_picture');
    
    // Load age verification status
    if (_prefs.containsKey('settings_is_over_21')) {
      _isOver21 = _prefs.getBool('settings_is_over_21');
    }
    _unitSystem = _prefs.getString('settings_unit_system') ?? _unitSystem;
  _seenOnboarding = _prefs.getBool('settings_seen_onboarding') ?? false;
    
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

  Future<void> setProfilePicture(String? path) async {
    _profilePicturePath = path;
    if (path == null) {
      await _prefs.remove('settings_profile_picture');
    } else {
      await _prefs.setString('settings_profile_picture', path);
    }
    notifyListeners();
  }

  Future<void> setAgeVerification(bool isOver21) async {
    _isOver21 = isOver21;
    await _prefs.setBool('settings_is_over_21', isOver21);
    notifyListeners();
  }

  Future<void> setUnitSystem(String system) async {
    if (system != 'us' && system != 'metric') return;
    _unitSystem = system;
    await _prefs.setString('settings_unit_system', _unitSystem);
    notifyListeners();
  }

  Future<void> setSeenOnboarding(bool value) async {
    _seenOnboarding = value;
    await _prefs.setBool('settings_seen_onboarding', _seenOnboarding);
    notifyListeners();
  }
}
