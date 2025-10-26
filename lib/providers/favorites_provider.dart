import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favorites = {};
  final Map<String, double> _ratings = {};
  late SharedPreferences _prefs;

  Set<String> get favorites => _favorites;
  Map<String, double> get ratings => _ratings;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
    _loadRatings();
  }

  void _loadFavorites() {
    final favList = _prefs.getStringList('favorites') ?? [];
    _favorites.addAll(favList);
    notifyListeners();
  }

  void _loadRatings() {
    final ratingKeys = _prefs.getKeys().where((key) => key.startsWith('rating_'));
    for (final key in ratingKeys) {
      final cocktailId = key.replaceFirst('rating_', '');
      _ratings[cocktailId] = _prefs.getDouble(key) ?? 0.0;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(String cocktailId) async {
    if (_favorites.contains(cocktailId)) {
      _favorites.remove(cocktailId);
    } else {
      _favorites.add(cocktailId);
    }
    await _prefs.setStringList('favorites', _favorites.toList());
    notifyListeners();
  }

  Future<void> rateCocktail(String cocktailId, double rating) async {
    _ratings[cocktailId] = rating;
    await _prefs.setDouble('rating_$cocktailId', rating);
    notifyListeners();
  }

  bool isFavorite(String cocktailId) => _favorites.contains(cocktailId);
  
  double getRating(String cocktailId) => _ratings[cocktailId] ?? 0.0;
}