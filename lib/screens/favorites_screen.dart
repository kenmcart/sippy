import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/cocktail_card.dart';
import '../providers/collections_provider.dart';
import 'list_detail_screen.dart';
import 'profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Collection'),
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Rated'),
              Tab(text: 'Lists'),
            ],
          ),
        ),
        body: Consumer3<CocktailProvider, FavoritesProvider, CollectionsProvider>(
          builder: (context, cocktailProvider, favoritesProvider, collectionsProvider, child) {
            final favorites = cocktailProvider.cocktails
                .where((c) => favoritesProvider.isFavorite(c['id']))
                .toList();
                
            final rated = cocktailProvider.cocktails
                .where((c) => favoritesProvider.getRating(c['id']) > 0)
                .toList();

            return TabBarView(
              children: [
                // Favorites Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return CocktailCard(cocktail: favorites[index]);
                  },
                ),
                // Rated Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rated.length,
                  itemBuilder: (context, index) {
                    final cocktail = rated[index];
                    final rating = favoritesProvider.getRating(cocktail['id']);
                    return CocktailCard(
                      cocktail: cocktail,
                      showRating: rating,
                    );
                  },
                ),
                // Lists Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.playlist_add),
                              label: const Text('Add List'),
                              onPressed: () async {
                                final name = await _promptForName(context, hint: 'List name');
                                if (name != null && name.trim().isNotEmpty) {
                                  await collectionsProvider.createList(name.trim());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: collectionsProvider.listNames.isEmpty
                            ? const Center(child: Text('No lists yet. Create one to start saving recipes.'))
                            : ListView.builder(
                                itemCount: collectionsProvider.listNames.length,
                                itemBuilder: (context, index) {
                                  final name = collectionsProvider.listNames[index];
                                  final count = collectionsProvider.countInList(name);
                                  return ListTile(
                                    leading: const Icon(Icons.list_alt),
                                    title: Text(name),
                                    subtitle: Text('$count recipe${count == 1 ? '' : 's'}'),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ListDetailScreen(listName: name),
                                        ),
                                      );
                                    },
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          tooltip: 'Rename',
                                          onPressed: () async {
                                            final newName = await _promptForName(context, initial: name, hint: 'Rename list');
                                            if (newName != null && newName.trim().isNotEmpty) {
                                              await collectionsProvider.renameList(name, newName.trim());
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            final ok = await _confirm(context, 'Delete "$name"?');
                                            if (ok == true) {
                                              await collectionsProvider.deleteList(name);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<String?> _promptForName(BuildContext context, {String? initial, String? hint}) async {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(hint ?? 'Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirm(BuildContext context, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}