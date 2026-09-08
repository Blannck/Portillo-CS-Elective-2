import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/shopify_app_bar.dart';

/// Screen displaying full details for a selected [Product].
/// 
/// Shows hero image, title, price, star ratings, description, and shipping perks.
/// Includes an interactive "Add to Bag" button with scale animation and cart navigation.
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
    // Setup button press feedback scale animation
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

  /// Handles "Add to Bag" button taps.
  /// 
  /// Triggers cart provider item insertion and button scale animation,
  /// or navigates to `/cart` if item was already added during this session.
  void _handleAddToCart() {
    if (_addedToCart) {
      context.push('/cart');
      return;
    }

    _buttonController.reverse().then((_) => _buttonController.forward());

    context.read<CartProvider>().addItem(widget.product);
    setState(() => _addedToCart = true);
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      appBar: ShopifyAppBar(title: 'Product Details', showBackButton: true),
      body: CustomScrollView(
        slivers: [
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(label: Text(product.category)),

                  const SizedBox(height: 10),

                  Text(product.name, style: theme.textTheme.headlineMedium),

                  const SizedBox(height: 8),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _RatingRow(
                    rating: product.rating,
                    reviewCount: product.reviewCount,
                  ),

                  const SizedBox(height: 20),

                  Divider(),

                  const SizedBox(height: 16),

                  Text('Description', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),

                  Text(product.description, style: theme.textTheme.bodyLarge),

                  const SizedBox(height: 24),

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

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
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

/// Helper widget rendering full, half, and outline star icons based on rating double.
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
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC200)),
        if (hasHalf)
          const Icon(
            Icons.star_half_rounded,
            size: 18,
            color: Color(0xFFFFC200),
          ),
        for (int i = fullStars + (hasHalf ? 1 : 0); i < 5; i++)
          Icon(
            Icons.star_outline_rounded,
            size: 18,
            color: const Color(0xFFFFC200),
          ),

        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text('  ·  $reviewCount reviews', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Helper row displaying an icon with informational text (shipping, returns, etc.).
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
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
