// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sippy/main.dart';
import 'package:sippy/providers/favorites_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create a mock FavoritesProvider
    final favoritesProvider = FavoritesProvider();
    await favoritesProvider.init();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(favoritesProvider: favoritesProvider));

    // Verify that our app title is shown
    expect(find.text('Sippy'), findsOneWidget);
  });
}
