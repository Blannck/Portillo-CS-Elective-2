import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/products_data.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

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

  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);

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
