import 'product.dart';

/// Represents one line-item in the shopping cart.
///
/// [quantity] is mutable because the user can increment/decrement it
/// via the cart screen's StatefulWidget controls.
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// Computed subtotal for this line-item.
  double get subtotal => product.price * quantity;
}
