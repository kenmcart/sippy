import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cocktail_provider.dart';
import '../widgets/cocktail_card.dart';
import '../widgets/filter_drawer.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    // Fetch cocktails when the screen initializes
    Future.microtask(() =>
      Provider.of<CocktailProvider>(context, listen: false).fetchCocktails()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CocktailProvider>(
      builder: (context, cocktailProvider, child) {
        final cocktails = cocktailProvider.cocktails;
        
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Sippy'),
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
          endDrawer: const FilterDrawer(),
          body: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cocktails.length,
            itemBuilder: (context, index) {
              return CocktailCard(cocktail: cocktails[index]);
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.filter_list),
            label: const Text('Filters'),
          ),
        );
      },
    );
  }
}