import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Entry point of the Shopify e-commerce application.
/// 
/// Initializes global state management providers ([ThemeProvider], [CartProvider])
/// at the top of the widget tree using [MultiProvider].
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Manages light/dark theme state
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Manages shopping cart items, quantities, and totals
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const ShopifyApp(),
    ),
  );
}

/// Root application widget.
/// 
/// Listens to [ThemeProvider] for dynamic theme switching (light/dark mode)
/// and configures routing via [GoRouter] ([appRouter]).
class ShopifyApp extends StatelessWidget {
  const ShopifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'Shopify',
          debugShowCheckedModeBanner: false,

          // Application themes configured in AppTheme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // GoRouter configuration for page navigation
          routerConfig: appRouter,
        );
      },
    );
  }
}

