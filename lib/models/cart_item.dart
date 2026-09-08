import 'product.dart';

/// Represents an individual item entry in the shopping cart, wrapping a [Product] and its quantity.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  /// Computes line-item subtotal (unit price multiplied by quantity).
  double get subtotal => product.price * quantity;
}

