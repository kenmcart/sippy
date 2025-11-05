import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/cocktail_provider.dart';
import '../widgets/age_verification_dialog.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Show age verification dialog after first frame if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAgeVerification();
    });
  }

  Future<void> _checkAgeVerification() async {
    final settings = context.read<SettingsProvider>();
    
    if (settings.needsAgeVerification) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AgeVerificationDialog(
          onOver21: () async {
            await settings.setAgeVerification(true);
            context.read<CocktailProvider>().setAgeRestriction(false);
            if (mounted) Navigator.of(context).pop();
          },
          onUnder21: () async {
            await settings.setAgeVerification(false);
            context.read<CocktailProvider>().setAgeRestriction(true);
            if (mounted) Navigator.of(context).pop();
          },
        ),
      );
    } else {
      // Apply existing age restriction
      context.read<CocktailProvider>().setAgeRestriction(settings.isOver21 == false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}