import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_image.dart';
import 'admin/add_edit_product_page.dart';
import 'customer/cart_page.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final int productId;
  final bool isAdmin;

  const ProductDetailPage({
    super.key,
    required this.productId,
    required this.isAdmin,
  });

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (!widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
            ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          final Product? product = products
              .cast<Product?>()
              .firstWhere((p) => p?.id == widget.productId, orElse: () => null);

          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final categoryName = categoriesAsync.maybeWhen(
            data: (cats) {
              final c = cats
                  .cast()
                  .firstWhere((cat) => cat.id == product.categoryId, orElse: () => null);
              return c?.name ?? 'Pickleball Gear';
            },
            orElse: () => 'Pickleball Gear',
          );

          final isOutOfStock = product.stock <= 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image
                SizedBox(
                  height: 300,
                  child: ProductImage(
                    imageUrl: product.imageUrl,
                    productName: product.name,
                    categoryId: product.categoryId,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Name
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),

                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? AppColors.error.withAlpha(25)
                                  : AppColors.success.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? 'Out of Stock'
                                  : '${product.stock} in stock',
                              style: TextStyle(
                                color: isOutOfStock
                                    ? AppColors.error
                                    : AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Description Section
                      const Text(
                        'Product Overview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description ??
                            'No technical specifications provided for this product.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Customer Actions: Quantity Selector & Add to Cart
                      if (!widget.isAdmin) ...[
                        if (!isOutOfStock) ...[
                          Row(
                            children: [
                              const Text(
                                'Quantity:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: _selectedQuantity > 1
                                          ? () => setState(
                                                () => _selectedQuantity--,
                                              )
                                          : null,
                                    ),
                                    Text(
                                      '$_selectedQuantity',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed:
                                          _selectedQuantity < product.stock
                                              ? () => setState(
                                                    () => _selectedQuantity++,
                                                  )
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Subtotal: \$${(product.price * _selectedQuantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: isOutOfStock
                                  ? Colors.grey.shade400
                                  : AppColors.primary,
                            ),
                            onPressed: isOutOfStock
                                ? null
                                : () {
                                    final err = ref
                                        .read(cartProvider.notifier)
                                        .addToCart(
                                          product,
                                          quantity: _selectedQuantity,
                                        );

                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    if (err != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(err),
                                          backgroundColor: AppColors.warning,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added $_selectedQuantity x "${product.name}" to cart',
                                          ),
                                          backgroundColor:
                                              AppColors.primaryDark,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: Text(
                              isOutOfStock
                                  ? 'Item Out of Stock'
                                  : 'Add to Cart',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Admin Actions: Edit Product
                      if (widget.isAdmin) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditProductPage(product: product),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Product in Catalog'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
