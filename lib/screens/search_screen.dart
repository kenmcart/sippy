import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import '../widgets/cocktail_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ingredientsController = TextEditingController();
  final List<String> _ingredients = [];

  @override
  void dispose() {
    _ingredientsController.dispose();
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
        title: const Text('Search by Ingredients'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Enter an ingredient',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addIngredient(_ingredientsController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _addIngredient,
            ),
          ),
          Wrap(
            spacing: 8,
            children: _ingredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                onDeleted: () => _removeIngredient(ingredient),
              );
            }).toList(),
          ),
          Expanded(
            child: Consumer<CocktailProvider>(
              builder: (context, cocktailProvider, child) {
                final filteredCocktails = cocktailProvider.filterCocktails(
                  availableIngredients: _ingredients,
                );

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