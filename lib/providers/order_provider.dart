import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'product_provider.dart';
import 'supabase_provider.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(supabaseProvider));
});

/// Customer's own order history
final customerOrdersProvider = FutureProvider<List<Order>>((ref) async {
  ref.watch(authStateProvider);
  return await ref.watch(orderServiceProvider).fetchCustomerOrders();
});

/// Admin view: all orders across all customers
class AllOrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() {
    ref.watch(authStateProvider);
    return ref.read(orderServiceProvider).fetchAllOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(orderServiceProvider).fetchAllOrders(),
    );
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    await ref.read(orderServiceProvider).updateOrderStatus(orderId, newStatus);
    final currentOrders = state.value ?? [];
    state = AsyncData(
      currentOrders.map((o) {
        if (o.id == orderId) {
          return o.copyWith(status: newStatus);
        }
        return o;
      }).toList(),
    );
  }
}

final allOrdersProvider =
    AsyncNotifierProvider<AllOrdersNotifier, List<Order>>(
  AllOrdersNotifier.new,
);

/// Checkout Controller: manages state during order submission
class CheckoutController extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    return null;
  }

  Future<Map<String, dynamic>> placeOrder() async {
    state = const AsyncLoading();
    final cartState = ref.read(cartProvider);

    if (cartState.isEmpty) {
      final err = Exception('Cart is empty.');
      state = AsyncError(err, StackTrace.current);
      throw err;
    }

    try {
      final orderResult =
          await ref.read(orderServiceProvider).checkout(cartState.items);

      // On successful order:
      // 1. Empty the cart as required
      ref.read(cartProvider.notifier).clearCart();
      // 2. Invalidate product list so stock counts refresh immediately
      ref.invalidate(productProvider);
      // 3. Invalidate customer and admin orders
      ref.invalidate(customerOrdersProvider);
      ref.invalidate(allOrdersProvider);

      state = AsyncData(orderResult);
      return orderResult;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final checkoutControllerProvider =
    AsyncNotifierProvider<CheckoutController, Map<String, dynamic>?>(
  CheckoutController.new,
);
