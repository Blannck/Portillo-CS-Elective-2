import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/products_data.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

/// Declarative application router configuration built with [GoRouter].

/// 
/// Defines app navigation structure, parameter parsing, route redirect guards,
/// and smooth custom transition animations for page navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Home Screen Route ──────────────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _homeTransition,
      ),
    ),

    // ── Product Details Route (with dynamic ID parameter) ─────────────────
    GoRoute(
      path: '/product/:id',
      name: 'product-detail',
      pageBuilder: (context, state) {
        // Extract product ID parameter from URL path
        final id = state.pathParameters['id']!;
        // Lookup product from catalog dataset
        final product = kProducts.firstWhere(
          (p) => p.id == id,
          orElse: () => kProducts.first,
        );
        return CustomTransitionPage(
          key: state.pageKey,
          child: ProductDetailScreen(product: product),
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: _slideRightTransition,
        );
      },
    ),

    // ── Cart Screen Route ─────────────────────────────────────────────────
    GoRoute(
      path: '/cart',
      name: 'cart',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CartScreen(),
        transitionDuration: const Duration(milliseconds: 340),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _slideRightTransition,
      ),
    ),

    // ── Checkout Confirmation Route (with Route Guard) ───────────────────
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      // Navigation Guard: Redirects user back to /cart if cart is empty
      redirect: (context, state) {
        final cart = context.read<CartProvider>();
        if (!cart.isNotEmpty) return '/cart';
        return null;
      },
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CheckoutConfirmationScreen(),
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
  ],

  // Fallback 404 page for unmatched routes
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);

/// Custom transition builder for Home Screen (fade with subtle push-back translation).
Widget _homeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final pushBackSlide =
      Tween<Offset>(begin: Offset.zero, end: const Offset(-0.18, 0.0)).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
      );

  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, _) =>
          FractionalTranslation(translation: pushBackSlide.value, child: child),
    ),
  );
}

/// Custom slide-right transition builder for detail and cart screens.
Widget _slideRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final enterSlide = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  final pushBackSlide =
      Tween<Offset>(begin: Offset.zero, end: const Offset(-0.18, 0.0)).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
      );

  return AnimatedBuilder(
    animation: Listenable.merge([animation, secondaryAnimation]),
    builder: (context, _) => FractionalTranslation(
      translation: enterSlide.value + pushBackSlide.value,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

/// Custom slide-up modal transition builder for checkout confirmation.
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final slide = Tween<Offset>(
    begin: const Offset(0.0, 1.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) => FractionalTranslation(
      translation: slide.value,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

