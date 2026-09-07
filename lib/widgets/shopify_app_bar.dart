import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';

/// A reusable [PreferredSizeWidget] AppBar styled after Shopify's admin UI.
///
/// Displays the Shopify wordmark (or custom [title]), a cart icon with an
/// animated item-count badge, and a dark-mode toggle icon button.
///
/// This is a [StatelessWidget] because it reads state from providers
/// but never owns mutable state itself.
class ShopifyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? extraActions;

  const ShopifyAppBar({
    super.key,
    this.title = 'Shopify',
    this.showBackButton = false,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final cartProvider = context.watch<CartProvider>();
    final itemCount = cartProvider.itemCount;

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle,
      ),
      actions: [
        // ── Dark / Light mode toggle ───────────────────────────────────────
        IconButton(
          tooltip: themeProvider.isDark ? 'Switch to light mode' : 'Switch to dark mode',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              themeProvider.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              key: ValueKey(themeProvider.isDark),
            ),
          ),
          onPressed: themeProvider.toggleTheme,
        ),

        // ── Cart icon with badge ───────────────────────────────────────────
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Cart',
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () => context.push('/cart'),
            ),
            if (itemCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(itemCount),
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      itemCount > 99 ? '99+' : '$itemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        ...?extraActions,
        const SizedBox(width: 4),
      ],
    );
  }
}
