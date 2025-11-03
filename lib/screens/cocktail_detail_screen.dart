import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/favorites_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/settings_provider.dart';
import '../utils/measure_utils.dart';
import '../providers/collections_provider.dart';

class CocktailDetailScreen extends StatefulWidget {
  final Map<String, dynamic> cocktail;

  const CocktailDetailScreen({
    super.key,
    required this.cocktail,
  });

  @override
  State<CocktailDetailScreen> createState() => _CocktailDetailScreenState();
}

class _CocktailDetailScreenState extends State<CocktailDetailScreen> {
  double _scale = 1.0; // 1x, 2x, 4x servings

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.cocktail['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              background: CachedNetworkImage(
                imageUrl: widget.cocktail['imageUrl'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.local_bar, size: 50),
                ),
              ),
            ),
            actions: [
              if (kIsWeb)
                IconButton(
                  tooltip: 'Copy recipe',
                  icon: const Icon(Icons.copy_all),
                  onPressed: () async {
                    final text = _composeShareText(context);
                    await Clipboard.setData(ClipboardData(text: text));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recipe copied to clipboard')),
                      );
                    }
                  },
                ),
              IconButton(
                tooltip: 'Save to list',
                icon: const Icon(Icons.playlist_add),
                onPressed: () => _showSaveToListSheet(context),
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Icons.ios_share),
                onPressed: () {
                  final text = _composeShareText(context);
                  Share.share(text);
                },
              ),
              Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.isFavorite(widget.cocktail['id']);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => favoritesProvider.toggleFavorite(widget.cocktail['id']),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      return RatingBar.builder(
                        initialRating: favoritesProvider.getRating(widget.cocktail['id']),
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          favoritesProvider.rateCocktail(widget.cocktail['id'], rating);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Batch calculator control
                  Row(
                    children: [
                      Text('Servings:', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 12),
                      SegmentedButton<double>(
                        segments: const [
                          ButtonSegment(value: 1.0, label: Text('1x')),
                          ButtonSegment(value: 2.0, label: Text('2x')),
                          ButtonSegment(value: 4.0, label: Text('4x')),
                        ],
                        selected: {_scale},
                        onSelectionChanged: (selection) {
                          if (selection.isNotEmpty) {
                            setState(() {
                              _scale = selection.first;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...List<Widget>.from(
                          (widget.cocktail['ingredients'] as List).map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.chevron_right),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _convertedIngredient(context, ingredient.toString()),
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(context, 'Skill: ${widget.cocktail['skill']}'),
                      _buildChip(context, 'Type: ${widget.cocktail['type']}'),
                      _buildChip(context, 'Potency: ${widget.cocktail['potency']}'),
                      ...List<Widget>.from(
                        (widget.cocktail['mood'] as List).map(
                          (mood) => _buildChip(context, mood),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recipe:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.cocktail['recipe'],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _composeShareText(BuildContext context) {
    final ingredients = (widget.cocktail['ingredients'] as List)
        .map((e) => '- ${_convertedIngredient(context, e.toString())}')
        .join('\n');

    final sb = StringBuffer();
    sb.writeln('${widget.cocktail['name']}');
    sb.writeln('');
    sb.writeln('Ingredients:');
    sb.writeln(ingredients);
    sb.writeln('');
    sb.writeln('Recipe:');
    sb.writeln(widget.cocktail['recipe']);
    sb.writeln('');
    sb.writeln('Shared from Sippy');
    return sb.toString();
  }

  String _convertedIngredient(BuildContext context, String ingredientLine) {
    final settings = context.read<SettingsProvider>();
    return MeasureUtils.convertLine(ingredientLine, settings.unitSystem, scale: _scale);
  }

  Future<void> _showSaveToListSheet(BuildContext context) async {
    final collections = context.read<CollectionsProvider>();
    final listNames = collections.listNames;
    String? selected;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final controller = TextEditingController();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Save "${widget.cocktail['name']}" to…', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (listNames.isEmpty)
                const Text('No lists yet. Create one below.'),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...listNames.map((name) => RadioListTile<String>(
                          title: Text(name),
                          value: name,
                          groupValue: selected,
                          onChanged: (v) {
                            selected = v;
                            Navigator.of(context).pop();
                          },
                        )),
                    const Divider(),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Create new list',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create and Save'),
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          await collections.createList(name);
                          selected = collections.listNames.firstWhere((n) => n.toLowerCase().startsWith(name.toLowerCase()));
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      await collections.addToList(selected!, widget.cocktail['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to "$selected"')),
        );
      }
    }
  }
}