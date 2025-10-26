import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  String? selectedSkill;
  String? selectedType;
  String? selectedPotency;
  String? selectedMood;
  int? maxIngredients;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load current filter state from provider
    final cocktailProvider = Provider.of<CocktailProvider>(context, listen: false);
    setState(() {
      selectedSkill = cocktailProvider.skillFilter;
      selectedType = cocktailProvider.typeFilter;
      selectedPotency = cocktailProvider.potencyFilter;
      selectedMood = cocktailProvider.moodFilter;
      maxIngredients = cocktailProvider.maxIngredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cocktailProvider = Provider.of<CocktailProvider>(context);
    final categories = cocktailProvider.categories;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Maximum Ingredients',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: (maxIngredients ?? 10).toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: maxIngredients?.toString() ?? 'Any',
              onChanged: (value) {
                setState(() {
                  maxIngredients = value.toInt();
                });
              },
            ),
            const Divider(),
            _buildCategoryFilter(
              'Skill Level',
              categories['skill']!,
              selectedSkill,
              (value) => setState(() => selectedSkill = value),
            ),
            const Divider(),
            _buildCategoryFilter(
              'Drink Type',
              categories['type']!,
              selectedType,
              (value) => setState(() => selectedType = value),
            ),
            const Divider(),
            _buildCategoryFilter(
              'Potency',
              categories['potency']!,
              selectedPotency,
              (value) => setState(() => selectedPotency = value),
            ),
            const Divider(),
            _buildCategoryFilter(
              'Mood',
              categories['mood']!,
              selectedMood,
              (value) => setState(() => selectedMood = value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cocktailProvider.applyFilters(
                  maxIngredients: maxIngredients,
                  skill: selectedSkill,
                  type: selectedType,
                  potency: selectedPotency,
                  mood: selectedMood,
                );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedSkill = null;
                  selectedType = null;
                  selectedPotency = null;
                  selectedMood = null;
                  maxIngredients = null;
                });
                cocktailProvider.clearFilters();
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
    String title,
    List<String> options,
    String? selectedValue,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Any'),
              selected: selectedValue == null,
              onSelected: (selected) {
                if (selected) {
                  onChanged(null);
                }
              },
            ),
            ...options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedValue == option,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                },
              );
            }),
          ],
        ),
      ],
    );
  }
}