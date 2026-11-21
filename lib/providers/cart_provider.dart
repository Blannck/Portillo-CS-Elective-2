import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => items.isEmpty;

  CartItem? findByProductId(int productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  /// Adds a product to cart with strict stock validation
  /// Returns a message if capped or fails, or null on clean success
  String? addToCart(Product product, {int quantity = 1}) {
    if (product.stock <= 0) {
      return 'Sorry, "${product.name}" is out of stock.';
    }

    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      final existingItem = state.items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity > product.stock) {
        // Cap at available stock
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: product.stock,
          product: product,
        );
        state = state.copyWith(items: updatedItems);
        return 'Only ${product.stock} in stock. Quantity adjusted to maximum.';
      } else {
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
          product: product,
        );
        state = state.copyWith(items: updatedItems);
        return null;
      }
    } else {
      final initialQuantity =
          quantity > product.stock ? product.stock : quantity;
      final newItem = CartItem(product: product, quantity: initialQuantity);
      state = state.copyWith(items: [...state.items, newItem]);

      if (quantity > product.stock) {
        return 'Only ${product.stock} in stock. Added maximum available.';
      }
      return null;
    }
  }

  /// Updates quantity of an item in cart
  String? updateQuantity(int productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return null;
    }

    final index = state.items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return null;

    final item = state.items[index];
    if (newQuantity > item.product.stock) {
      final updatedList = List<CartItem>.from(state.items);
      updatedList[index] = item.copyWith(quantity: item.product.stock);
      state = state.copyWith(items: updatedList);
      return 'Maximum available stock is ${item.product.stock}.';
    }

    final updatedList = List<CartItem>.from(state.items);
    updatedList[index] = item.copyWith(quantity: newQuantity);
    state = state.copyWith(items: updatedList);
    return null;
  }

  /// Removes an item completely from cart
  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  /// Empties the cart (called on checkout completion and on logout)
  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
