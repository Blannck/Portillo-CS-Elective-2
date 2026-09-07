import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:prelimexam/main.dart';
import 'package:prelimexam/providers/cart_provider.dart';
import 'package:prelimexam/providers/theme_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const ShopifyApp(),
      ),
    );
    // App should build successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
