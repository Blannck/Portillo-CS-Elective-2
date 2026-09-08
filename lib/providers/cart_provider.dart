import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Manages shopping cart state across the app using [ChangeNotifier].
/// 
/// Stores items in an internal map keyed by product ID for efficient O(1) operations.
/// Exposes getters for item counts and subtotal totals, and triggers [notifyListeners]
/// whenever cart state updates.
class CartProvider extends ChangeNotifier {
  /// Internal cart storage map: Product ID -> CartItem instance.
  final Map<String, CartItem> _items = {};

  /// Returns an unmodifiable list of current cart items.
  List<CartItem> get items => List.unmodifiable(_items.values.toList());

  /// Calculates the total count of individual units in the cart.
  int get itemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Calculates the total gross price of all items in the cart.
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Returns true if the cart contains at least one item.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Adds a product to the cart or increments its quantity if already present.
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  /// Decrements product quantity by 1, or removes item completely if quantity drops to 0.
  void decrementItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  /// Increments product quantity by 1.
  void incrementItem(String productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  /// Removes a product entirely from the cart regardless of quantity.
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Empties all items from the cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Helper to return current quantity of a given product ID (defaults to 0).
  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  /// Checks whether a specific product is currently in the cart.
  bool contains(String productId) => _items.containsKey(productId);
}

