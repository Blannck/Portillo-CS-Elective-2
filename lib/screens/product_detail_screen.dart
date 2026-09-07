import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/shopify_app_bar.dart';

/// Displays full details for a single product.
///
/// Reached via go_router's [GoRoute] at `/product/:id` — Navigation 2.0.
///
/// [StatefulWidget] justification:
///   - Owns [_addedToCart] — a boolean that flips when the user taps
///     "Add to Cart", changing the button's icon and label ("Add to Cart" →
///     "Added to Bag ✓"). This transient UI state doesn't belong in CartProvider.
///   - Owns [_imageLoading] to show a shimmer while the hero image loads.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _addedToCart = false;
  late final AnimationController _buttonController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _buttonController;
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _handleAddToCart() {
    if (_addedToCart) {
      // Already added — navigate to cart
      context.push('/cart');
      return;
    }

    // Animate button press
    _buttonController.reverse().then((_) => _buttonController.forward());

    context.read<CartProvider>().addItem(widget.product);
    setState(() => _addedToCart = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      appBar: ShopifyAppBar(
        title: 'Product Details',
        showBackButton: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Product image (Hero animation from grid) ───────────────────
          SliverToBoxAdapter(
            child: Hero(
              tag: 'product-image-${product.id}',
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                height: 380,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 380,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 380,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_outlined,
                    size: 60,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),

          // ── Product details ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Chip(label: Text(product.category)),

                  const SizedBox(height: 10),

                  // Product name
                  Text(product.name, style: theme.textTheme.headlineMedium),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rating bar
                  _RatingRow(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                  ),

                  const SizedBox(height: 20),

                  Divider(),

                  const SizedBox(height: 16),

                  // Description heading
                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),

                  // Product description
                  Text(
                    product.description,
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  // Shipping info
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Free shipping on orders over \$50',
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.refresh_rounded,
                    label: '30-day free returns',
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.verified_outlined,
                    label: '2-year quality guarantee',
                  ),

                  // Bottom padding for sticky button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky "Add to Cart" bottom bar ─────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border(
            top: BorderSide(color: theme.dividerColor),
          ),
        ),
        child: Row(
          children: [
            // Quantity in cart indicator
            Consumer<CartProvider>(
              builder: (context, cart, _) {
                final qty = cart.quantityOf(product.id);
                if (qty == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$qty in bag',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),

            // Add to Cart button — state changes to "Added ✓" after first tap
            Expanded(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ElevatedButton.icon(
                  onPressed: _handleAddToCart,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      _addedToCart
                          ? Icons.shopping_bag_rounded
                          : Icons.add_shopping_cart_rounded,
                      key: ValueKey(_addedToCart),
                    ),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _addedToCart ? 'Go to Bag' : 'Add to Bag',
                      key: ValueKey(_addedToCart),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting StatelessWidgets ───────────────────────────────────────────────

/// Displays star rating and review count.
/// [StatelessWidget] — purely derived from passed-in numbers.
class _RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _RatingRow({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        // Filled stars
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC200)),
        // Half star
        if (hasHalf)
          const Icon(Icons.star_half_rounded, size: 18, color: Color(0xFFFFC200)),
        // Empty stars
        for (int i = fullStars + (hasHalf ? 1 : 0); i < 5; i++)
          Icon(Icons.star_outline_rounded,
              size: 18, color: const Color(0xFFFFC200)),

        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          '  ·  $reviewCount reviews',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// A simple icon + label info row.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
