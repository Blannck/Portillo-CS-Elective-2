import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Manages the shopping cart state.
///
/// This is a [ChangeNotifier] because the cart is mutable shared state
/// that the AppBar badge, CartScreen, and CheckoutScreen all depend on.
/// Any mutation (add, remove, quantity change) notifies all listeners to rebuild.
class CartProvider extends ChangeNotifier {
  /// Internal map of product ID → [CartItem].
  final Map<String, CartItem> _items = {};

  /// Unmodifiable view of the current cart items.
  List<CartItem> get items => List.unmodifiable(_items.values.toList());

  /// Total number of individual units in the cart (for badge display).
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Grand total price of all items in the cart.
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Whether the cart has at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Adds [product] to the cart, or increments quantity if already present.
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  /// Decrements quantity of [productId] by 1; removes the item if quantity hits 0.
  void decrementItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Increments quantity of [productId] by 1.
  void incrementItem(String productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  /// Removes an item entirely from the cart.
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Clears all items from the cart (called after checkout).
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Returns the quantity of [productId] currently in the cart, or 0.
  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  /// Returns true if [productId] is in the cart.
  bool contains(String productId) => _items.containsKey(productId);
}
