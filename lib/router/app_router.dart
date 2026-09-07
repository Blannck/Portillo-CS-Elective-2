import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/products_data.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

/// Navigation 2.0 router using [GoRouter] with coordinated two-page transitions.
///
/// Every [transitionsBuilder] receives both [animation] (this page's enter/exit)
/// AND [secondaryAnimation] (how this page moves when another is pushed ON TOP).
/// Using both produces the classic iOS-style parallel motion:
///   push  → new page slides in from right; underlying page slides slightly left
///   pop   → top page slides back right; underlying page slides back to center
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
    GoRoute(
      path: '/product/:id',
      name: 'product-detail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
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
    GoRoute(
      path: '/checkout',
      name: 'checkout',
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

  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);

// ── Transition builders ────────────────────────────────────────────────────────

/// Home page transition.
///
/// Primary  [animation]          → fade in/out (home itself entering/leaving).
/// Secondary [secondaryAnimation] → slides home slightly LEFT when a detail page
///   is pushed on top, then slides it back to centre on pop. This creates the
///   coordinated two-page motion that makes the navigation feel physically smooth.
Widget _homeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Slides home back when a page is pushed on top; slides home forward on pop.
  final pushBackSlide = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.18, 0.0),
  ).animate(CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInOut,
  ));

  return FadeTransition(
    // Home itself fades in when first opened (e.g. after checkout clear).
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
    child: AnimatedBuilder(
      animation: secondaryAnimation,
      builder: (context, _) => FractionalTranslation(
        translation: pushBackSlide.value,
        child: child,
      ),
    ),
  );
}

/// Slide-right transition — used for Product Detail and Cart.
///
/// Primary  [animation]          → slides in from the RIGHT on push,
///                                  slides back to the RIGHT on pop.
/// Secondary [secondaryAnimation] → when yet another page pushes on top of this
///   one (e.g. Cart → Checkout), this page slides slightly LEFT, then returns.
///
/// Combined via [FractionalTranslation] so both motions happen in one layer.
Widget _slideRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // This page's own enter/exit (slide from the right).
  final enterSlide = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

  // Gets pushed aside when a child page slides on top.
  final pushBackSlide = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.18, 0.0),
  ).animate(CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInOut,
  ));

  return AnimatedBuilder(
    // Listen to both animations so we always pick up the combined offset.
    animation: Listenable.merge([animation, secondaryAnimation]),
    builder: (context, _) => FractionalTranslation(
      // Adding the two offsets combines the "enter" and "pushed-aside" motions.
      translation: enterSlide.value + pushBackSlide.value,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

/// Slide-up transition — used for the Checkout Confirmation screen.
///
/// Slides in from the bottom (modal/completion sheet feel). No secondary
/// animation since checkout is always the last page in the stack.
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
