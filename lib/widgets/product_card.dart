import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../pages/admin/add_edit_product_page.dart';
import '../pages/product_detail_page.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import 'product_image.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final bool isAdmin;

  const ProductCard({
    super.key,
    required this.product,
    required this.isAdmin,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(productProvider.notifier).deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${product.name}" successfully'),
              backgroundColor: AppColors.courtNavy,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _onAddToCart(BuildContext context, WidgetRef ref) {
    final errorMsg =
        ref.read(cartProvider.notifier).addToCart(product, quantity: 1);

    ScaffoldMessenger.of(context).clearSnackBars();
    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Added "${product.name}" to cart'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = product.stock <= 0;
    final isLowStock = product.stock > 0 && product.stock <= 5;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                productId: product.id,
                isAdmin: isAdmin,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image with Badges & Admin Actions Overlay
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Appropriate Product Image
                  ProductImage(
                    imageUrl: product.imageUrl,
                    productName: product.name,
                    categoryId: product.categoryId,
                    fit: BoxFit.cover,
                  ),

                  // Stock status tag (top left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: isOutOfStock
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'OUT OF STOCK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : isLowStock
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ONLY ${product.stock} LEFT',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),

                  // Admin Action Buttons (top right overlay)
                  if (isAdmin)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withAlpha(220),
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              color: AppColors.courtNavy,
                              tooltip: 'Edit Product',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditProductPage(product: product),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withAlpha(220),
                            child: IconButton(
                              icon: const Icon(Icons.delete, size: 16),
                              color: AppColors.error,
                              tooltip: 'Delete Product',
                              onPressed: () => _confirmDelete(context, ref),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Product Details Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),

                    // Price and Stock line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isOutOfStock
                                ? AppColors.error
                                : AppColors.slateMuted,
                            fontWeight: isOutOfStock
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    // Customer: Add to cart button
                    if (!isAdmin)
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock
                                ? Colors.grey.shade300
                                : AppColors.primary,
                            foregroundColor: isOutOfStock
                                ? Colors.grey.shade600
                                : Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isOutOfStock
                              ? null
                              : () => _onAddToCart(context, ref),
                          icon: const Icon(Icons.add_shopping_cart, size: 15),
                          label: Text(
                            isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_tennis, size: 40, color: AppColors.primary),
            SizedBox(height: 4),
            Text(
              'PicklePro',
              style: TextStyle(
                color: AppColors.slateMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
