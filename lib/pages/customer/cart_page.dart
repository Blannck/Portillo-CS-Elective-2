import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'checkout_confirmation_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  Future<void> _handleCheckout(BuildContext context, WidgetRef ref) async {
    try {
      final orderResult =
          await ref.read(checkoutControllerProvider.notifier).placeOrder();

      final orderId = orderResult['order_id'];
      final totalPaid =
          double.tryParse(orderResult['total']?.toString() ?? '') ?? 0.0;

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutConfirmationPage(
              orderId: orderId is int
                  ? orderId
                  : int.tryParse(orderId.toString()) ?? 0,
              totalAmount: totalPaid,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Checkout error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final isCheckingOut = checkoutState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (!cartState.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
              },
            ),
        ],
      ),
      body: cartState.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.courtNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse our premier pickleball collection and add items to your cart.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slateMuted),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Explore Catalog'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final item = cartState.items[index];
                      return _buildCartItemTile(context, ref, item);
                    },
                  ),
                ),

                // Order Summary & Checkout Bottom Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Items (${cartState.totalCount})',
                              style: const TextStyle(
                                color: AppColors.slateMuted,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '\$${cartState.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.courtNavy,
                              ),
                            ),
                            Text(
                              '\$${cartState.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Checkout Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: isCheckingOut
                                ? null
                                : () => _handleCheckout(context, ref),
                            icon: isCheckingOut
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_outline),
                            label: Text(
                              isCheckingOut
                                  ? 'Verifying Stock & Processing...'
                                  : 'Place Order (\$${cartState.totalPrice.toStringAsFixed(2)})',
                              style: const TextStyle(
                                fontSize: 16,
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
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) {
    final p = item.product;
    final isMaxStock = item.quantity >= p.stock;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              clipBehavior: Clip.antiAlias,
              child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                  ? Image.network(
                      p.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_tennis,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.sports_tennis,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 12),

            // Name & Unit Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${p.price.toStringAsFixed(2)} each',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (isMaxStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Max available (${p.stock})',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Quantity Controls (- / count / +)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.slateMuted,
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .updateQuantity(p.id, item.quantity - 1);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 22,
                    color: isMaxStock
                        ? Colors.grey.shade400
                        : AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: isMaxStock
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot exceed stock of ${p.stock}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      : () {
                          final msg = ref
                              .read(cartProvider.notifier)
                              .updateQuantity(p.id, item.quantity + 1);
                          if (msg != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(width: 8),
                // Remove Item Button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: AppColors.error,
                  ),
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    ref.read(cartProvider.notifier).removeItem(p.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
