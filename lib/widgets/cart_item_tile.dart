import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/cart_item.dart';

/// Displays a single row in the cart or checkout summary.
///
/// This is a [StatelessWidget] because the tile only reads from a [CartItem]
/// snapshot passed by the parent. All quantity mutation logic lives in the
/// parent [CartScreen] (a StatefulWidget) and is passed as callbacks.
class CartItemTile extends StatelessWidget {
  final CartItem item;

  /// Called when the user taps the increment (+) button. Null = button hidden.
  final VoidCallback? onIncrement;

  /// Called when the user taps the decrement (-) button. Null = button hidden.
  final VoidCallback? onDecrement;

  /// Called when the user taps the remove (trash) button. Null = button hidden.
  final VoidCallback? onRemove;

  /// If true, shows quantity controls. Set false for read-only checkout summary.
  final bool showControls;

  const CartItemTile({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product thumbnail ────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: 72,
              height: 88,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 72,
                height: 88,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (context, url, error) => Container(
                width: 72,
                height: 88,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.image_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Product info + controls ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category label
                Text(
                  item.product.category.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),

                // Product name
                Text(
                  item.product.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Unit price
                Text(
                  '\$${item.product.price.toStringAsFixed(2)} each',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),

                // ── Quantity controls or static quantity ─────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showControls)
                      _QuantityControl(
                        quantity: item.quantity,
                        onDecrement: onDecrement,
                        onIncrement: onIncrement,
                      )
                    else
                      Text(
                        'Qty: ${item.quantity}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    // Subtotal for this line-item
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Remove button ──────────────────────────────────────────────
          if (showControls && onRemove != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: onRemove,
              tooltip: 'Remove item',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Internal quantity stepper widget for the cart tile.
///
/// Extracted here to keep [CartItemTile.build] clean.
class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _QuantityControl({
    required this.quantity,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: onDecrement,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 16),
      ),
    );
  }
}
