import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_card.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  'Failed to load order history: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(customerOrdersProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No past orders found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.courtNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'When you checkout, your orders and items will be saved here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slateMuted),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Start Shopping'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(customerOrdersProvider);
              await ref.read(customerOrdersProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, index) {
                final order = orders[index];
                return OrderCard(order: order, isAdmin: false);
              },
            ),
          );
        },
      ),
    );
  }
}
