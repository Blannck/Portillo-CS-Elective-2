import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    // MultiProvider at the root so every screen can access cart + theme state.
    MultiProvider(
      providers: [
        // ThemeProvider — mutable state for light/dark mode toggle.
        // The entire app listens and rebuilds when toggleTheme() is called.
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // CartProvider — mutable state for shopping cart operations.
        // AppBar badge, CartScreen, and CheckoutScreen all depend on this.
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const ShopifyApp(),
    ),
  );
}

/// Root widget of the application.
///
/// [StatelessWidget] here is intentional — it reads [ThemeProvider] via
/// [Consumer] and passes [ThemeMode] down to [MaterialApp.router].
/// [ThemeProvider] is the mutable source of truth; [ShopifyApp] itself
/// never owns any state.
class ShopifyApp extends StatelessWidget {
  const ShopifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp.router(
          title: 'Shopify',
          debugShowCheckedModeBanner: false,

          // ── Theming ─────────────────────────────────────────────────────
          // Single ThemeData for light and dark applied at the MaterialApp level.
          // No widget below should ever hardcode a color value.
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // ── Navigation 2.0 ──────────────────────────────────────────────
          // go_router handles URL-based navigation with deep-link support
          // and a redirect guard for the /checkout route.
          routerConfig: appRouter,
        );
      },
    );
  }
}
