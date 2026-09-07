import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/shopify_app_bar.dart';

/// Shopping cart screen showing all added items with live quantity controls.
///
/// [StatefulWidget] justification:
///   - While cart state itself lives in [CartProvider], this screen needs to
///     rebuild immediately on quantity changes (increment/decrement). Using
///     [Consumer] handles provider rebuilds, but the screen also manages its
///     own local UI state such as which item (if any) is being swiped to delete.
///   - The running total displayed in the bottom bar updates live — this is
///     derived from [CartProvider] state and rebuilds via [Consumer].
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShopifyAppBar(
        title: 'Your Bag',
        showBackButton: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (!cart.isNotEmpty) {
            return _EmptyCart();
          }

          return Column(
            children: [
              // ── Cart item list ─────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemTile(
                      item: item,
                      showControls: true,
                      onIncrement: () => cart.incrementItem(item.product.id),
                      onDecrement: () => cart.decrementItem(item.product.id),
                      onRemove: () => _confirmRemove(context, cart, item.product.id, item.product.name),
                    );
                  },
                ),
              ),

              // ── Order summary + checkout ───────────────────────────────
              _OrderSummaryPanel(cart: cart),
            ],
          );
        },
      ),
    );
  }

  /// Shows a snackbar-style confirmation before removing an item.
  void _confirmRemove(
    BuildContext context,
    CartProvider cart,
    String productId,
    String productName,
  ) {
    cart.removeItem(productId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$productName removed from bag'),
        action: SnackBarAction(
          label: 'Undo',
          // TODO: implement undo by re-adding the item
          onPressed: () {},
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ── Order summary panel ───────────────────────────────────────────────────────
/// [StatelessWidget] — reads from [CartProvider] snapshot passed from parent.
/// Displays subtotal breakdown and the checkout CTA button.
class _OrderSummaryPanel extends StatelessWidget {
  final CartProvider cart;

  const _OrderSummaryPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = cart.totalPrice;
    final shipping = subtotal >= 50 ? 0.0 : 5.99;
    final total = subtotal + shipping;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal row
          _SummaryRow(
            label: 'Subtotal (${cart.itemCount} items)',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),

          // Shipping row
          _SummaryRow(
            label: 'Shipping',
            value: shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}',
            valueColor: shipping == 0 ? theme.colorScheme.primary : null,
          ),
          const SizedBox(height: 10),
          Divider(),
          const SizedBox(height: 10),

          // Total row
          _SummaryRow(
            label: 'Total',
            value: '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 16),

          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/checkout'),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isBold
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

// ── Empty cart ────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text('Your bag is empty', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Add items from the store to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
