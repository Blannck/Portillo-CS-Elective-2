import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/shopify_app_bar.dart';

/// Final checkout confirmation screen shown after the user completes purchase.
///
/// Reachable only after at least one item is in the cart — enforced by the
/// go_router redirect guard in [AppRouter].
///
/// [StatelessWidget] justification:
///   - This screen only reads a snapshot of the cart and displays it.
///   - It never mutates data and has no interactive state after being built.
///   - The "Continue Shopping" action navigates away, clearing the cart —
///     that mutation happens in [CartProvider] (ChangeNotifier), not here.
class CheckoutConfirmationScreen extends StatelessWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.read<CartProvider>();
    // Snapshot the cart items BEFORE clearing, so the summary remains visible.
    final items = List.of(cart.items);
    final subtotal = cart.totalPrice;
    final shipping = subtotal >= 50 ? 0.0 : 5.99;
    final total = subtotal + shipping;

    return Scaffold(
      appBar: const ShopifyAppBar(
        title: 'Order Confirmed',
      ),
      body: CustomScrollView(
        slivers: [
          // ── Success banner ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SuccessBanner(),
          ),

          // ── Order summary heading ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('Order Summary', style: theme.textTheme.headlineSmall),
            ),
          ),

          // ── Items list (read-only) ──────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == items.length) {
                  return const Divider(height: 1);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (index > 0) const Divider(height: 1),
                      CartItemTile(
                        item: items[index],
                        showControls: false, // Read-only on confirmation
                      ),
                    ],
                  ),
                );
              },
              childCount: items.length + 1,
            ),
          ),

          // ── Price breakdown ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _Row(
                        label: 'Subtotal (${items.length} items)',
                        value: '\$${subtotal.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Shipping',
                        value: shipping == 0
                            ? 'Free'
                            : '\$${shipping.toStringAsFixed(2)}',
                        valueStyle: shipping == 0
                            ? TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Divider(),
                      const SizedBox(height: 12),
                      _Row(
                        label: 'Total Charged',
                        value: '\$${total.toStringAsFixed(2)}',
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        valueStyle: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Confirmation message ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Successful',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'A confirmation email has been sent to your inbox. Your order will arrive in 3–5 business days.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Continue shopping button ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Continue Shopping'),
                      onPressed: () {
                        // Clear the cart and return to home
                        context.read<CartProvider>().clearCart();
                        context.go('/');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Track Your Order'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order tracking coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primary.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order Placed!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thank you for shopping with Shopify',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(60),
              ),
            ),
            child: Text(
              'Order #${DateTime.now().millisecondsSinceEpoch % 100000}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _Row({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? theme.textTheme.bodyMedium),
        Text(value, style: valueStyle ?? theme.textTheme.bodyMedium),
      ],
    );
  }
}
