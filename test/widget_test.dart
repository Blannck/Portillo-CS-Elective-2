import 'package:flutter_test/flutter_test.dart';
import 'package:final_exam/models/product.dart';
import 'package:final_exam/models/cart_item.dart';
import 'package:final_exam/providers/cart_provider.dart';

void main() {
  group('Pickleball E-Commerce Unit Tests', () {
    test('Product model creation and calculation', () {
      final product = Product(
        id: 1,
        name: 'Selkirk Vanguard Control',
        description: 'Elite raw carbon paddle',
        price: 199.99,
        stock: 5,
        categoryId: 1,
      );

      expect(product.id, 1);
      expect(product.name, 'Selkirk Vanguard Control');
      expect(product.price, 199.99);
      expect(product.stock, 5);
      expect(product.isOutOfStock, false);
      expect(product.isLowStock, true);
    });

    test('CartItem subtotal calculation', () {
      final product = Product(
        id: 2,
        name: 'Franklin X-40 Pickleballs (12-Pack)',
        price: 34.99,
        stock: 20,
        categoryId: 3,
      );

      final cartItem = CartItem(product: product, quantity: 3);
      expect(cartItem.quantity, 3);
      expect(cartItem.subtotal, closeTo(104.97, 0.001));
    });

    test('CartState totals and stock limit checks', () {
      final p1 = Product(
        id: 1,
        name: 'Paddle',
        price: 100.0,
        stock: 2,
        categoryId: 1,
      );
      final p2 = Product(
        id: 2,
        name: 'Shoes',
        price: 50.0,
        stock: 5,
        categoryId: 2,
      );

      final state = CartState(items: [
        CartItem(product: p1, quantity: 2),
        CartItem(product: p2, quantity: 1),
      ]);

      expect(state.totalCount, 3);
      expect(state.totalPrice, 250.0);
      expect(state.isEmpty, false);
    });
  });
}
