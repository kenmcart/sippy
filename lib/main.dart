import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/cocktail_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.init();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  
  runApp(MyApp(
    favoritesProvider: favoritesProvider,
    settingsProvider: settingsProvider,
  ));
}

class MyApp extends StatelessWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;
  
  const MyApp({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CocktailProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sippy',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: child!,
                ),
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: 'Decrement',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
