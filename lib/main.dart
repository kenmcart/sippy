import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/cocktail_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: Make sure to update firebase_options.dart with your Firebase project config
  bool firebaseInitSuccess = false;
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    debugPrint('🔍 Platform: ${kIsWeb ? "Web" : defaultTargetPlatform}');
    debugPrint('🔍 Options: ${options != null ? "Found" : "NULL!"}');
    if (options == null) {
      throw Exception('FirebaseOptions is null! Check firebase_options.dart');
    }
    debugPrint('🔍 API Key: ${options.apiKey}');
    debugPrint('🔍 Project ID: ${options.projectId}');
    
    await Firebase.initializeApp(
      options: options,
    );
    firebaseInitSuccess = true;
    debugPrint('✅ Firebase initialized successfully');
    debugPrint('Firebase apps count: ${Firebase.apps.length}');
    debugPrint('Firebase app name: ${Firebase.apps.first.name}');
  } catch (e, stackTrace) {
    // If Firebase is not configured, we'll handle it gracefully
    // The AuthProvider will detect this and show appropriate messages
    firebaseInitSuccess = false;
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    debugPrint('Please configure Firebase to enable authentication. See FIREBASE_QUICK_SETUP.md');
    // Print to console so user can see it in browser
    print('FIREBASE_INIT_ERROR: $e');
  }
  
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.init();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  final collectionsProvider = CollectionsProvider();
  await collectionsProvider.init();
  final authProvider = AuthProvider();
  await authProvider.initialize();
  
  runApp(MyApp(
    favoritesProvider: favoritesProvider,
    settingsProvider: settingsProvider,
    collectionsProvider: collectionsProvider,
    authProvider: authProvider,
  ));
}

class MyApp extends StatelessWidget {
  final FavoritesProvider favoritesProvider;
  final SettingsProvider settingsProvider;
  final CollectionsProvider collectionsProvider;
  final AuthProvider authProvider;
  
  const MyApp({
    super.key,
    required this.favoritesProvider,
    required this.settingsProvider,
    required this.collectionsProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CocktailProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: collectionsProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, auth, _) {
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
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

