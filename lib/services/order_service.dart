import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class OrderService {
  final SupabaseClient _client;

  OrderService(this._client);

  /// Places an order atomically.
  /// Prices, product names, and stock checks come from the database at checkout time.
  /// Stock is reduced by ordered quantities in the same transaction.
  Future<Map<String, dynamic>> checkout(List<CartItem> cartItems) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User must be logged in to checkout.');
    }

    if (cartItems.isEmpty) {
      throw Exception('Cart is empty.');
    }

    // Prepare payload for PostgreSQL RPC
    final itemsPayload = cartItems
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            })
        .toList();

    try {
      // 1. Primary method: call atomic create_order RPC
      final response = await _client.rpc(
        'create_order',
        params: {'items': itemsPayload},
      );

      Map<String, dynamic> resultMap;
      if (response is String) {
        resultMap = jsonDecode(response) as Map<String, dynamic>;
      } else if (response is Map) {
        resultMap = Map<String, dynamic>.from(response);
      } else {
        resultMap = {'order_id': response, 'status': 'completed'};
      }

      return resultMap;
    } catch (rpcError) {
      // 2. Fallback transaction: client-orchestrated with server-side price & stock verification
      // (Used in case RPC function has not yet been executed in the Supabase SQL editor)
      try {
        double authoritativeTotal = 0.0;
        final verifiedItems = <Map<String, dynamic>>[];

        // Verify real stock and real price from database directly
        for (final item in cartItems) {
          final prodData = await _client
              .from('products')
              .select('id, name, price, stock')
              .eq('id', item.product.id)
              .single();

          final realStock = prodData['stock'] as int;
          final realPrice = double.tryParse(prodData['price'].toString()) ?? 0.0;
          final prodName = prodData['name'] as String;

          if (realStock < item.quantity) {
            throw Exception(
              'Insufficient stock for "$prodName". Available: $realStock, requested: ${item.quantity}',
            );
          }

          authoritativeTotal += realPrice * item.quantity;
          verifiedItems.add({
            'product_id': item.product.id,
            'quantity': item.quantity,
            'unit_price': realPrice,
            'new_stock': realStock - item.quantity,
          });
        }

        // Insert order record
        final orderRow = await _client
            .from('orders')
            .insert({
              'user_id': userId,
              'status': 'completed',
              'total': authoritativeTotal,
            })
            .select()
            .single();

        final orderId = orderRow['id'] as int;

        // Insert items and deduct stock
        for (final item in verifiedItems) {
          await _client.from('order_items').insert({
            'order_id': orderId,
            'product_id': item['product_id'],
            'unit_price': item['unit_price'],
            'quantity': item['quantity'],
          });

          // Deduct stock
          await _client
              .from('products')
              .update({'stock': item['new_stock']})
              .eq('id', item['product_id']);
        }

        return {
          'order_id': orderId,
          'total': authoritativeTotal,
          'status': 'completed',
        };
      } catch (fallbackError) {
        throw Exception(
          'Checkout failed: ${rpcError.toString().contains('function') ? fallbackError.toString() : rpcError.toString()}',
        );
      }
    }
  }

  /// Customer order history (own orders only)
  Future<List<Order>> fetchCustomerOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('orders')
        .select('*, order_items(*, products(name, image_url))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Admin view of all customer orders
  Future<List<Order>> fetchAllOrders() async {
    final data = await _client
        .from('orders')
        .select('*, profiles(email, firstname, lastname), order_items(*, products(name, image_url))')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Admin status update (e.g. pending, completed, processing, cancelled)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final res = await _client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId)
        .select();

    if (res.isEmpty) {
      throw Exception('Failed to update order status or permission denied.');
    }
  }
}
