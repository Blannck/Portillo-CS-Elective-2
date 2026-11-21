import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order_card.dart';

class AdminOrderListPage extends ConsumerWidget {
  const AdminOrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Orders (Admin)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: () => ref.read(allOrdersProvider.notifier).refresh(),
          ),
        ],
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
                  'Failed to load orders: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(allOrdersProvider.notifier).refresh(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.slateMuted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders placed yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.courtNavy,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Customer orders will appear here automatically.',
                    style: TextStyle(color: AppColors.slateMuted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(allOrdersProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (ctx, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  isAdmin: true,
                  onStatusChanged: (newStatus) async {
                    try {
                      await ref
                          .read(allOrdersProvider.notifier)
                          .updateStatus(order.id, newStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order #${order.id} status updated to "$newStatus"',
                            ),
                            backgroundColor: AppColors.courtNavy,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update status: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
