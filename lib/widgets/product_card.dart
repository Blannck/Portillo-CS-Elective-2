import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';

/// Displays a single product tile inside the home grid.
///
/// [StatefulWidget] justification:
///   - Owns [_isPressed] — a boolean that flips on TapDown / TapUp / TapCancel
///     to drive a subtle press-scale animation. The product data is still
///     immutable; only the transient visual press state requires [setState].
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.push('/product/${widget.product.id}');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        // Slight scale-down on press gives tactile feedback without a ripple.
        scale: _isPressed ? 0.965 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          // Elevation effect: shadow grows on hover / press for a "lift" feel.
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            // Elevation already 0 in CardTheme — shadow handled by outer
            // AnimatedContainer so we can animate it smoothly.
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Product image ────────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: 'product-image-${widget.product.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Product info ─────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category label
                        Text(
                          widget.product.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Product name
                        Text(
                          widget.product.name,
                          style: theme.textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Star rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFFFC200),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.product.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' (${widget.product.reviewCount})',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Price
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
