import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import '../widgets/cocktail_card.dart';
import 'profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ingredientsController = TextEditingController();
  final _nameController = TextEditingController();
  final List<String> _ingredients = [];
  String _searchMode = 'ingredients'; // 'ingredients' or 'name'

  @override
  void dispose() {
    _ingredientsController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !_ingredients.contains(ingredient.toLowerCase())) {
      setState(() {
        _ingredients.add(ingredient.toLowerCase());
      });
      _ingredientsController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Cocktails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Search mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'name',
                  label: Text('By Name'),
                  icon: Icon(Icons.local_bar),
                ),
                ButtonSegment(
                  value: 'ingredients',
                  label: Text('By Ingredients'),
                  icon: Icon(Icons.food_bank),
                ),
              ],
              selected: {_searchMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _searchMode = newSelection.first;
                  _nameController.clear();
                  _ingredients.clear();
                  _ingredientsController.clear();
                });
              },
            ),
          ),
          
          // Search input based on mode
          if (_searchMode == 'name')
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Search drink name',
                  hintText: 'e.g., Mojito, Margarita',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            )
          else
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _ingredientsController,
                    decoration: InputDecoration(
                      labelText: 'Enter an ingredient',
                      hintText: 'e.g., vodka, lime',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addIngredient(_ingredientsController.text),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: _addIngredient,
                  ),
                ),
                if (_ingredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: _ingredients.map((ingredient) {
                        return Chip(
                          label: Text(ingredient),
                          onDeleted: () => _removeIngredient(ingredient),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          
          Expanded(
            child: Consumer<CocktailProvider>(
              builder: (context, cocktailProvider, child) {
                final filteredCocktails = _searchMode == 'name'
                    ? cocktailProvider.filterCocktails(
                        searchName: _nameController.text,
                      )
                    : cocktailProvider.filterCocktails(
                        availableIngredients: _ingredients,
                      );

                if (filteredCocktails.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchMode == 'name' ? Icons.search_off : Icons.liquor,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchMode == 'name'
                              ? 'No drinks found'
                              : _ingredients.isEmpty
                                  ? 'Add ingredients to search'
                                  : 'No cocktails with these ingredients',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredCocktails.length,
                  itemBuilder: (context, index) {
                    return CocktailCard(cocktail: filteredCocktails[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}