import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CocktailProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cocktails = [];
  List<Map<String, dynamic>> _filteredCocktails = [];
  Map<String, List<String>> _categories = {
    'skill': ['beginner', 'intermediate', 'expert'],
    'type': ['fruity', 'tart', 'sweet', 'bitter', 'savory'],
    'potency': ['non-alcoholic', 'light', 'medium', 'strong'],
    'mood': ['breakfast', 'brunch', 'lunch', 'dinner', 'party', 'relaxing'],
  };

  // Active filters
  int? _maxIngredients;
  String? _skillFilter;
  String? _typeFilter;
  String? _potencyFilter;
  String? _moodFilter;

  // Flag to skip remote loading (useful for testing)
  final bool skipRemoteLoad;
  
  // Age restriction flag
  bool _showOnlyNonAlcoholic = false;

  CocktailProvider({this.skipRemoteLoad = false});

  List<Map<String, dynamic>> get cocktails {
    var result = _filteredCocktails.isEmpty && !_hasActiveFilters() ? _cocktails : _filteredCocktails;
    
    // Apply age restriction filter
    if (_showOnlyNonAlcoholic) {
      result = result.where((c) => c['potency'] == 'non-alcoholic').toList();
    }
    
    return result;
  }
  
  Map<String, List<String>> get categories => _categories;
  
  // Getters for current filter state
  int? get maxIngredients => _maxIngredients;
  String? get skillFilter => _skillFilter;
  String? get typeFilter => _typeFilter;
  String? get potencyFilter => _potencyFilter;
  String? get moodFilter => _moodFilter;
  
  void setAgeRestriction(bool showOnlyNonAlcoholic) {
    _showOnlyNonAlcoholic = showOnlyNonAlcoholic;
    notifyListeners();
  }

  bool _hasActiveFilters() {
    return _maxIngredients != null ||
           _skillFilter != null ||
           _typeFilter != null ||
           _potencyFilter != null ||
           _moodFilter != null;
  }

  Future<void> fetchCocktails() async {
    _cocktails = [
      {
        'id': '1',
        'name': 'Classic Mojito',
        'ingredients': ['White rum (2 oz)', 'Fresh lime juice (1 oz)', 'Simple syrup (0.75 oz)', 'Fresh mint leaves (8-10)', 'Soda water', 'Crushed ice'],
        'recipe': '1. Gently muddle mint leaves with simple syrup in a highball glass\n2. Add fresh lime juice and rum\n3. Fill glass with crushed ice\n4. Top with soda water\n5. Garnish with mint sprig and lime wheel',
        'skill': 'beginner',
        'type': 'fruity',
        'potency': 'medium',
        'mood': ['party', 'summer', 'relaxing'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/metwgh1606770327.jpg',
      },
      {
        'id': '2',
        'name': 'Old Fashioned',
        'ingredients': ['Bourbon (2 oz)', 'Angostura bitters (2-3 dashes)', 'Sugar cube (1)', 'Orange peel', 'Ice cubes'],
        'recipe': '1. Place sugar cube in rocks glass\n2. Add bitters and a splash of water\n3. Muddle until sugar dissolves\n4. Add bourbon and ice cubes\n5. Stir well\n6. Express orange peel over drink and drop in',
        'skill': 'intermediate',
        'type': 'bitter',
        'potency': 'strong',
        'mood': ['evening', 'relaxing'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/vrwquq1478252802.jpg',
      },
      {
        'id': '3',
        'name': 'Espresso Martini',
        'ingredients': ['Vodka (2 oz)', 'Coffee liqueur (1 oz)', 'Fresh espresso (1 oz)', 'Simple syrup (0.5 oz)', 'Coffee beans for garnish'],
        'recipe': '1. Brew espresso and let it cool\n2. Add all ingredients to shaker with ice\n3. Shake vigorously for 10-15 seconds\n4. Double strain into chilled martini glass\n5. Garnish with three coffee beans',
        'skill': 'intermediate',
        'type': 'bitter',
        'potency': 'strong',
        'mood': ['brunch', 'party'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/n0sx531504372951.jpg',
      },
      {
        'id': '4',
        'name': 'Mimosa',
        'ingredients': ['Champagne or Prosecco (4 oz)', 'Orange juice (2 oz)', 'Orange slice for garnish'],
        'recipe': '1. Fill champagne flute 2/3 full with chilled champagne\n2. Top with orange juice\n3. Gently stir\n4. Garnish with orange slice',
        'skill': 'beginner',
        'type': 'fruity',
        'potency': 'light',
        'mood': ['brunch', 'breakfast'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/juhcuu1504370685.jpg',
      },
      {
        'id': '5',
        'name': 'Margarita',
        'ingredients': ['Tequila (2 oz)', 'Triple sec (1 oz)', 'Fresh lime juice (1 oz)', 'Salt for rim', 'Ice cubes', 'Lime wheel for garnish'],
        'recipe': '1. Rub lime wedge around rim and dip in salt\n2. Add tequila, triple sec, and lime juice to shaker with ice\n3. Shake well for 10-15 seconds\n4. Strain into glass with ice\n5. Garnish with lime wheel',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['party', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/5noda61589575158.jpg',
      },
      {
        'id': '6',
        'name': 'Piña Colada',
        'ingredients': ['White rum (2 oz)', 'Coconut cream (2 oz)', 'Pineapple juice (2 oz)', 'Crushed ice', 'Pineapple wedge and cherry for garnish'],
        'recipe': '1. Add rum, coconut cream, and pineapple juice to blender\n2. Add crushed ice\n3. Blend until smooth\n4. Pour into hurricane glass\n5. Garnish with pineapple wedge and cherry',
        'skill': 'beginner',
        'type': 'sweet',
        'potency': 'medium',
        'mood': ['party', 'summer'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/cpf4j51504371346.jpg',
      },
      {
        'id': '7',
        'name': 'Negroni',
        'ingredients': ['Gin (1 oz)', 'Campari (1 oz)', 'Sweet vermouth (1 oz)', 'Orange peel', 'Ice cubes'],
        'recipe': '1. Add gin, Campari, and sweet vermouth to mixing glass\n2. Fill with ice and stir well\n3. Strain into rocks glass with large ice cube\n4. Express orange peel over drink and garnish',
        'skill': 'intermediate',
        'type': 'bitter',
        'potency': 'strong',
        'mood': ['dinner', 'evening'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/qgdu971561574065.jpg',
      },
      {
        'id': '8',
        'name': 'Virgin Sunrise',
        'ingredients': ['Orange juice (4 oz)', 'Grenadine (0.5 oz)', 'Sprite or 7-Up (2 oz)', 'Ice cubes', 'Orange slice and cherry for garnish'],
        'recipe': '1. Fill glass with ice cubes\n2. Pour orange juice\n3. Add Sprite or 7-Up\n4. Slowly pour grenadine (it will sink)\n5. Garnish with orange slice and cherry',
        'skill': 'beginner',
        'type': 'fruity',
        'potency': 'non-alcoholic',
        'mood': ['breakfast', 'brunch'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/trptts1454514474.jpg',
      },
      {
        'id': '9',
        'name': 'Moscow Mule',
        'ingredients': ['Vodka (2 oz)', 'Ginger beer (4-6 oz)', 'Fresh lime juice (0.5 oz)', 'Ice cubes', 'Lime wheel and mint for garnish'],
        'recipe': '1. Fill copper mug with ice\n2. Add vodka and lime juice\n3. Top with ginger beer\n4. Gently stir\n5. Garnish with lime wheel and mint sprig',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['party', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/3pylqc1504370988.jpg',
      },
      {
        'id': '10',
        'name': 'Bloody Mary',
        'ingredients': ['Vodka (2 oz)', 'Tomato juice (4 oz)', 'Lemon juice (0.5 oz)', 'Worcestershire sauce', 'Hot sauce', 'Salt and pepper', 'Celery stick'],
        'recipe': '1. Rim glass with salt and pepper\n2. Fill with ice\n3. Add vodka, tomato juice, lemon juice\n4. Add 2-3 dashes each of Worcestershire and hot sauce\n5. Stir well\n6. Garnish with celery stick',
        'skill': 'intermediate',
        'type': 'savory',
        'potency': 'medium',
        'mood': ['brunch', 'breakfast'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/t6caa21582485702.jpg',
      },
      {
        'id': '11',
        'name': 'Daiquiri',
        'ingredients': ['White rum (2 oz)', 'Fresh lime juice (1 oz)', 'Simple syrup (0.5 oz)', 'Ice'],
        'recipe': '1. Add ingredients to shaker with ice\n2. Shake well and double strain into chilled coupe\n3. Garnish with lime twist',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['summer', 'party'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/mrz9091589574515.jpg',
      },
      {
        'id': '12',
        'name': 'Manhattan',
        'ingredients': ['Rye whiskey (2 oz)', 'Sweet vermouth (1 oz)', 'Angostura bitters (2 dashes)', 'Cherry for garnish'],
        'recipe': '1. Stir ingredients with ice in mixing glass\n2. Strain into chilled coupe\n3. Garnish with cherry',
        'skill': 'intermediate',
        'type': 'bitter',
        'potency': 'strong',
        'mood': ['evening', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/yk70e31606771240.jpg',
      },
      {
        'id': '13',
        'name': 'Cosmopolitan',
        'ingredients': ['Vodka (1.5 oz)', 'Triple sec (1 oz)', 'Cranberry juice (0.5 oz)', 'Fresh lime juice (0.5 oz)'],
        'recipe': '1. Add all ingredients to shaker with ice\n2. Shake and strain into chilled martini glass\n3. Garnish with lime wheel',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['party', 'brunch'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/kpsajh1504368362.jpg',
      },
      {
        'id': '14',
        'name': 'Whiskey Sour',
        'ingredients': ['Bourbon (2 oz)', 'Fresh lemon juice (0.75 oz)', 'Simple syrup (0.75 oz)', 'Egg white (optional)'],
        'recipe': '1. Dry shake ingredients (if using egg) then add ice and shake\n2. Strain into rocks glass over ice\n3. Garnish with cherry and orange slice',
        'skill': 'intermediate',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['evening', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/hbkfsh1589574990.jpg',
      },
      {
        'id': '15',
        'name': 'Paloma',
        'ingredients': ['Tequila (2 oz)', 'Fresh grapefruit juice (2 oz)', 'Lime juice (0.5 oz)', 'Soda water', 'Salt for rim'],
        'recipe': '1. Rim glass with salt (optional)\n2. Add tequila and juices over ice\n3. Top with soda water\n4. Garnish with grapefruit wedge',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['party', 'summer'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/samm5j1513706393.jpg',
      },
      
      {
        'id': '17',
        'name': 'Tom Collins',
        'ingredients': ['Gin (2 oz)', 'Fresh lemon juice (1 oz)', 'Simple syrup (0.5 oz)', 'Soda water', 'Lemon wheel'],
        'recipe': '1. Add gin, lemon juice and syrup to shaker with ice\n2. Shake lightly and strain into Collins glass over ice\n3. Top with soda water\n4. Garnish with lemon wheel',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'light',
        'mood': ['lunch', 'summer'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/qystvv1439907682.jpg',
      },
      {
        'id': '18',
        'name': 'Pisco Sour',
        'ingredients': ['Pisco (2 oz)', 'Fresh lime juice (1 oz)', 'Simple syrup (0.75 oz)', 'Egg white', 'Angostura bitters'],
        'recipe': '1. Dry shake all ingredients, then add ice and shake again\n2. Strain into chilled glass\n3. Add a few drops of bitters on foam',
        'skill': 'intermediate',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['brunch', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/loezxn1504373874.jpg',
      },
      
      {
        'id': '20',
        'name': 'Dark \u0027n\u0027 Stormy',
        'ingredients': ['Dark rum (2 oz)', 'Ginger beer (4 oz)', 'Lime wedge'],
        'recipe': '1. Fill glass with ice\n2. Add rum and top with ginger beer\n3. Garnish with lime wedge',
        'skill': 'beginner',
        'type': 'spicy',
        'potency': 'medium',
        'mood': ['party', 'dinner'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/t1tn0s1504374905.jpg',
      },
      {
        'id': '21',
        'name': 'Aperol Spritz',
        'ingredients': ['Aperol (2 oz)', 'Prosecco (3 oz)', 'Soda water (1 oz)', 'Orange slice'],
        'recipe': '1. Fill wine glass with ice\n2. Add Aperol and prosecco, top with soda\n3. Garnish with orange slice',
        'skill': 'beginner',
        'type': 'bitter',
        'potency': 'light',
        'mood': ['summer', 'aperitif'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/iloasq1587661955.jpg',
      },
      {
        'id': '22',
        'name': 'Caipirinha',
        'ingredients': ['Cacha\u00e7a (50ml)', 'Lime (1/2, cut into wedges)', 'Sugar (2 tsp)', 'Crushed ice'],
        'recipe': '1. Muddle lime and sugar in glass\n2. Add crushed ice and cacha\u00e7a\n3. Stir and serve',
        'skill': 'beginner',
        'type': 'tart',
        'potency': 'medium',
        'mood': ['summer', 'party'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/jgvn7p1582484435.jpg',
      },
      {
        'id': '23',
        'name': 'Vesper Martini',
        'ingredients': ['Gin (3 oz)', 'Vodka (1 oz)', 'Lillet Blanc (0.5 oz)', 'Lemon peel'],
        'recipe': '1. Shake ingredients with ice (or stir if preferred)\n2. Strain into chilled martini glass\n3. Garnish with lemon peel',
        'skill': 'expert',
        'type': 'dry',
        'potency': 'strong',
        'mood': ['evening', 'elegant'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/mtdxpa1504374514.jpg',
      },
      
      {
        'id': '25',
        'name': 'Boulevardier',
        'ingredients': ['Bourbon (1 oz)', 'Campari (1 oz)', 'Sweet vermouth (1 oz)', 'Orange twist'],
        'recipe': '1. Stir ingredients with ice\n2. Strain into rocks glass with ice\n3. Garnish with orange twist',
        'skill': 'intermediate',
        'type': 'bitter',
        'potency': 'strong',
        'mood': ['evening'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/km84qi1513705868.jpg',
      },
      
      {
        'id': '27',
        'name': 'Ramos Gin Fizz',
        'ingredients': ['Gin (2 oz)', 'Fresh lemon juice (0.5 oz)', 'Fresh lime juice (0.5 oz)', 'Simple syrup (0.5 oz)', 'Egg white', 'Cream (1 oz)', 'Orange flower water', 'Soda water'],
        'recipe': '1. Dry shake then shake with ice thoroughly to create foam\n2. Strain into highball and top with soda water',
        'skill': 'expert',
        'type': 'frothy',
        'potency': 'light',
        'mood': ['brunch', 'special'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/967t911643844053.jpg',
      },
      {
        'id': '28',
        'name': 'Mint Julep',
        'ingredients': ['Bourbon (2 oz)', 'Fresh mint', 'Simple syrup (0.5 oz)', 'Crushed ice'],
        'recipe': '1. Muddle mint with syrup in julep cup\n2. Add bourbon and crushed ice\n3. Stir and garnish with mint sprig',
        'skill': 'beginner',
        'type': 'herbal',
        'potency': 'strong',
        'mood': ['summer', 'party'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/squyyq1439907312.jpg',
      },
      
      {
        'id': '30',
        'name': 'Long Island Iced Tea',
        'ingredients': ['Vodka (0.5 oz)', 'Tequila (0.5 oz)', 'Rum (0.5 oz)', 'Gin (0.5 oz)', 'Triple sec (0.5 oz)', 'Fresh lemon juice (1 oz)', 'Cola (top)'],
        'recipe': '1. Add spirits and lemon juice to shaker with ice\n2. Shake gently and pour into highball glass over ice\n3. Top with cola and stir',
        'skill': 'intermediate',
        'type': 'mixed',
        'potency': 'strong',
        'mood': ['party'],
        'imageUrl': 'https://www.thecocktaildb.com/images/media/drink/wx7hsg1504370510.jpg',
      },
    ];
    _filteredCocktails = _cocktails; // Initialize filtered list
    notifyListeners();

    // Kick off background load from TheCocktailDB to add many more drinks
    // (non-blocking to keep initial UI responsive)
    if (!skipRemoteLoad) {
      loadFromCocktailDB();
    }
  }

  // Load a large set of cocktails from TheCocktailDB by iterating a-z and 0-9.
  // Merges results into the local dataset with sensible defaults for custom fields.
  Future<void> loadFromCocktailDB() async {
    final letters = 'abcdefghijklmnopqrstuvwxyz0123456789'.split('');

    // Build a fast lookup for existing IDs to avoid duplicates
    final existingIds = _cocktails.map((c) => c['id']?.toString()).toSet();

    for (final ch in letters) {
      try {
        final uri = Uri.parse('https://www.thecocktaildb.com/api/json/v1/1/search.php?f=$ch');
        final resp = await http.get(uri);
        if (resp.statusCode != 200) continue;
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final drinks = data['drinks'] as List<dynamic>?;
        if (drinks == null) continue;

        for (final d in drinks) {
          final drink = (d as Map).cast<String, dynamic>();
          final id = drink['idDrink']?.toString();
          if (id == null || existingIds.contains(id)) continue;

          final name = drink['strDrink']?.toString() ?? 'Unknown';
          final imageUrl = drink['strDrinkThumb']?.toString() ?? '';
          final instructions = drink['strInstructions']?.toString() ?? '';
          final category = drink['strCategory']?.toString();
          final alcoholic = drink['strAlcoholic']?.toString();

          final ingredients = <String>[];
          for (int i = 1; i <= 15; i++) {
            final ing = drink['strIngredient$i']?.toString();
            final meas = drink['strMeasure$i']?.toString();
            if (ing != null && ing.trim().isNotEmpty) {
              final m = (meas == null || meas.trim().isEmpty) ? '' : ' (${meas.trim()})';
              ingredients.add('${ing.trim()}$m');
            }
          }

          // Map CocktailDB fields into our app's categories with conservative defaults
          final mappedType = _mapCategoryToType(category);
          final mappedPotency = (alcoholic != null && alcoholic.toLowerCase().contains('non'))
              ? 'non-alcoholic'
              : 'medium';

          final newItem = {
            'id': id,
            'name': name,
            'ingredients': ingredients.isEmpty ? ['See recipe'] : ingredients,
            'recipe': instructions,
            'skill': 'beginner',
            'type': mappedType,
            'potency': mappedPotency,
            'mood': ['party'],
            'imageUrl': imageUrl,
          };

          _cocktails.add(newItem);
          existingIds.add(id);
        }

        // After each batch, refresh filtered view according to current filters
        if (_hasActiveFilters()) {
          applyFilters(
            maxIngredients: _maxIngredients,
            skill: _skillFilter,
            type: _typeFilter,
            potency: _potencyFilter,
            mood: _moodFilter,
          );
        } else {
          _filteredCocktails = _cocktails;
          notifyListeners();
        }
      } catch (_) {
        // Ignore errors for individual batches to keep overall load resilient
        continue;
      }
    }
  }

  String _mapCategoryToType(String? category) {
    if (category == null) return 'fruity';
    final c = category.toLowerCase();
    if (c.contains('milk') || c.contains('shake') || c.contains('cocoa') || c.contains('soft') || c.contains('float')) {
      return 'sweet';
    }
    if (c.contains('beer')) {
      return 'bitter';
    }
    if (c.contains('coffee') || c.contains('tea')) {
      return 'bitter';
    }
    if (c.contains('punch') || c.contains('party')) {
      return 'fruity';
    }
    if (c.contains('shot')) {
      return 'bitter';
    }
    // Default most mixed cocktails to 'fruity' for broader discovery
    return 'fruity';
  }

  void applyFilters({
    int? maxIngredients,
    String? skill,
    String? type,
    String? potency,
    String? mood,
  }) {
    _maxIngredients = maxIngredients;
    _skillFilter = skill;
    _typeFilter = type;
    _potencyFilter = potency;
    _moodFilter = mood;

    _filteredCocktails = _cocktails.where((cocktail) {
      bool matches = true;
      
      if (maxIngredients != null) {
        matches &= cocktail['ingredients'].length <= maxIngredients;
      }
      
      if (skill != null) {
        matches &= cocktail['skill'] == skill;
      }
      
      if (type != null) {
        matches &= cocktail['type'] == type;
      }
      
      if (potency != null) {
        matches &= cocktail['potency'] == potency;
      }
      
      if (mood != null) {
        matches &= cocktail['mood'].contains(mood);
      }
      
      return matches;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _maxIngredients = null;
    _skillFilter = null;
    _typeFilter = null;
    _potencyFilter = null;
    _moodFilter = null;
    _filteredCocktails = _cocktails;
    notifyListeners();
  }

  List<Map<String, dynamic>> filterCocktails({
    int? maxIngredients,
    String? skill,
    String? type,
    String? potency,
    String? mood,
    List<String>? availableIngredients,
    String? searchName,
  }) {
    return _cocktails.where((cocktail) {
      bool matches = true;
      
      if (maxIngredients != null) {
        matches &= cocktail['ingredients'].length <= maxIngredients;
      }
      
      if (skill != null) {
        matches &= cocktail['skill'] == skill;
      }
      
      if (type != null) {
        matches &= cocktail['type'] == type;
      }
      
      if (potency != null) {
        matches &= cocktail['potency'] == potency;
      }
      
      if (mood != null) {
        matches &= cocktail['mood'].contains(mood);
      }
      
      if (searchName != null && searchName.trim().isNotEmpty) {
        final name = cocktail['name']?.toString().toLowerCase() ?? '';
        final query = searchName.toLowerCase().trim();
        matches &= name.contains(query);
      }
      
      if (availableIngredients != null && availableIngredients.isNotEmpty) {
        final needles = availableIngredients
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.toLowerCase().trim())
            .toList();

        bool anyIngredientMatches = false;

        for (final ingRaw in (cocktail['ingredients'] as List)) {
          final ing = ingRaw.toString().toLowerCase();
          
          for (final needle in needles) {
            // Match if the needle appears as a word/substring in the ingredient
            // This catches: vodka in "Vodka (2 oz)", lime in "Fresh lime juice", etc.
            if (ing.contains(needle)) {
              anyIngredientMatches = true;
              break;
            }
          }
          if (anyIngredientMatches) break;
        }

        matches &= anyIngredientMatches;
      }
      
      return matches;
    }).toList();
  }

  Map<String, dynamic>? getById(String id) {
    for (final c in _cocktails) {
      if (c['id']?.toString() == id) return c;
    }
    return null;
  }
}