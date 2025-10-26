import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/cocktail_card.dart';
import 'profile_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
            ],
          ),
        ),
        body: Consumer2<CocktailProvider, FavoritesProvider>(
          builder: (context, cocktailProvider, favoritesProvider, child) {
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
                    return CocktailCard(cocktail: rated[index]);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}