import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  // Map of list name -> list of cocktail IDs
  final Map<String, List<String>> _lists = {};

  Map<String, List<String>> get lists => _lists;
  List<String> get listNames => _lists.keys.toList()..sort();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    final jsonStr = _prefs.getString('collections_lists');
    if (jsonStr == null) return;
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      _lists.clear();
      decoded.forEach((key, value) {
        final items = (value as List).map((e) => e.toString()).toList();
        _lists[key] = items;
      });
      notifyListeners();
    } catch (_) {
      // ignore corrupted
    }
  }

  Future<void> _save() async {
    final map = <String, List<String>>{};
    map.addAll(_lists);
    await _prefs.setString('collections_lists', jsonEncode(map));
  }

  bool exists(String name) => _lists.containsKey(name);

  String _uniqueName(String desired) {
    if (!exists(desired)) return desired;
    int i = 2;
    while (exists('$desired ($i)')) {
      i++;
    }
    return '$desired ($i)';
  }

  Future<void> createList(String name) async {
    final n = _uniqueName(name.trim().isEmpty ? 'New List' : name.trim());
    _lists[n] = [];
    await _save();
    notifyListeners();
  }

  Future<void> deleteList(String name) async {
    _lists.remove(name);
    await _save();
    notifyListeners();
  }

  Future<void> renameList(String oldName, String newName) async {
    if (!_lists.containsKey(oldName)) return;
    final nn = _uniqueName(newName.trim().isEmpty ? oldName : newName.trim());
    if (nn == oldName) return;
    final items = _lists.remove(oldName)!;
    _lists[nn] = items;
    await _save();
    notifyListeners();
  }

  Future<void> addToList(String listName, String cocktailId) async {
    final items = _lists[listName] ?? [];
    if (!items.contains(cocktailId)) {
      items.add(cocktailId);
      _lists[listName] = items;
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeFromList(String listName, String cocktailId) async {
    final items = _lists[listName];
    if (items == null) return;
    items.remove(cocktailId);
    await _save();
    notifyListeners();
  }

  List<String> getList(String listName) => List<String>.from(_lists[listName] ?? const []);

  int countInList(String listName) => _lists[listName]?.length ?? 0;

  bool isInList(String listName, String cocktailId) => _lists[listName]?.contains(cocktailId) ?? false;
}
