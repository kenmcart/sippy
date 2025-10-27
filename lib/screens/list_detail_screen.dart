import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/collections_provider.dart';
import '../providers/cocktail_provider.dart';
import 'cocktail_detail_screen.dart';

class ListDetailScreen extends StatelessWidget {
  final String listName;
  const ListDetailScreen({super.key, required this.listName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
      ),
      body: Consumer2<CollectionsProvider, CocktailProvider>(
        builder: (context, collections, cocktails, child) {
          final ids = collections.getList(listName);
          if (ids.isEmpty) {
            return const Center(child: Text('No recipes in this list yet.'));
          }
          return ListView.separated(
            itemCount: ids.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final id = ids[index];
              final cocktail = cocktails.getById(id);
              if (cocktail == null) {
                // Orphaned id, allow user to remove
                return Dismissible(
                  key: ValueKey('orphan_$id'),
                  background: _buildSwipeBg(Colors.red, Icons.delete),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    collections.removeFromList(listName, id);
                  },
                  child: ListTile(
                    leading: const Icon(Icons.local_bar_outlined),
                    title: Text('Unknown (#$id)'),
                    subtitle: const Text('Tap to remove'),
                  ),
                );
              }
              return Dismissible(
                key: ValueKey(id),
                background: _buildSwipeBg(Colors.red, Icons.delete),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  collections.removeFromList(listName, id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Removed from list')),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: cocktail['imageUrl'] != null && cocktail['imageUrl'].toString().isNotEmpty
                        ? NetworkImage(cocktail['imageUrl'])
                        : null,
                    child: (cocktail['imageUrl'] == null || cocktail['imageUrl'].toString().isEmpty)
                        ? const Icon(Icons.local_bar)
                        : null,
                  ),
                  title: Text(cocktail['name'] ?? 'Unnamed'),
                  subtitle: Text(
                    (cocktail['ingredients'] as List).take(2).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CocktailDetailScreen(cocktail: cocktail),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSwipeBg(Color color, IconData icon) {
    return Container(
      color: color,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }
}
