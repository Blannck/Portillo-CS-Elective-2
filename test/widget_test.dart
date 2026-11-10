import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:backend_filter_pagination/models/product.dart';
import 'package:backend_filter_pagination/providers/product_provider.dart';
import 'package:backend_filter_pagination/services/supabase_service.dart';
import 'package:backend_filter_pagination/widgets/price_slider_filter.dart';
import 'package:backend_filter_pagination/widgets/pagination_bar.dart';
import 'package:backend_filter_pagination/widgets/product_card.dart';

// Fake Supabase Service for testing without live network
class FakeSupabaseService extends SupabaseService {
  List<Product> mockProducts = List.generate(
    18,
    (i) => Product(
      id: i + 1,
      name: 'Product ${i + 1}',
      price: (i + 1) * 10.0,
      stock: 10,
      description: 'Description for product ${i + 1}',
    ),
  );

  @override
  Future<({List<Product> products, int totalCount})> fetchProducts({
    required double minPrice,
    required double maxPrice,
    required int page,
    required int pageSize,
    String? searchQuery,
    String sortBy = 'id',
    bool ascending = true,
  }) async {
    var filtered = mockProducts.where((p) {
      if (p.price < minPrice || p.price > maxPrice) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!p.name.toLowerCase().contains(searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == 'price') {
        return ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
      }
      return ascending ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
    });

    final from = (page - 1) * pageSize;
    final to = (from + pageSize).clamp(0, filtered.length);
    final paged = from >= filtered.length ? <Product>[] : filtered.sublist(from, to);

    return (products: paged, totalCount: filtered.length);
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> updates) async {
    final idx = mockProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final updated = mockProducts[idx].copyWith(
        name: updates['name'] as String?,
        price: (updates['price'] as num?)?.toDouble(),
        stock: updates['stock'] as int?,
      );
      mockProducts[idx] = updated;
      return updated;
    }
    throw Exception('Product not found');
  }

  @override
  Future<void> deleteProduct(int id) async {
    mockProducts.removeWhere((p) => p.id == id);
  }

  @override
  Future<Product> insertProduct(Map<String, dynamic> productData) async {
    final newId = mockProducts.length + 1;
    final newProduct = Product(
      id: newId,
      name: productData['name'] as String,
      price: (productData['price'] as num).toDouble(),
      stock: productData['stock'] as int? ?? 0,
      description: productData['description'] as String?,
    );
    mockProducts.add(newProduct);
    return newProduct;
  }
}

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson parses correctly', () {
      final json = {
        'id': 10,
        'name': 'Running Shoes',
        'price': 120.50,
        'stock': 15,
        'category_id': 2,
        'description': 'Comfortable runners',
        'image_url': 'https://example.com/shoe.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, 10);
      expect(product.name, 'Running Shoes');
      expect(product.price, 120.50);
      expect(product.stock, 15);
      expect(product.categoryId, 2);
      expect(product.description, 'Comfortable runners');
      expect(product.imageUrl, 'https://example.com/shoe.jpg');
    });

    test('Product.toJson outputs valid map', () {
      const product = Product(
        id: 5,
        name: 'Sneakers',
        price: 99.00,
        stock: 8,
      );

      final json = product.toJson();

      expect(json['id'], 5);
      expect(json['name'], 'Sneakers');
      expect(json['price'], 99.00);
      expect(json['stock'], 8);
    });

    test('Product copyWith works correctly', () {
      const product = Product(id: 1, name: 'Boot', price: 100);
      final updated = product.copyWith(price: 150);
      expect(updated.price, 150);
      expect(updated.name, 'Boot');
      expect(updated.id, 1);
    });
  });

  group('ProductProvider Pagination & Filter Logic', () {
    test('Calculates totalPages correctly for various counts and page sizes (6-8 items)', () {
      final provider = ProductProvider();

      // Page size 6 default
      expect(provider.pageSize, 6);
      expect(provider.currentPage, 1);

      // Verify page size limits (6 to 8 max items per page)
      provider.setPageSize(7);
      expect(provider.pageSize, 7);

      provider.setPageSize(8);
      expect(provider.pageSize, 8);

      // Reject sizes outside 6-8
      provider.setPageSize(10);
      expect(provider.pageSize, 8);
      provider.setPageSize(4);
      expect(provider.pageSize, 8);
    });

    test('Fetches with fake service and paginates through 3 pages of 6 items', () async {
      final fake = FakeSupabaseService();
      final provider = ProductProvider(supabaseService: fake);

      await provider.fetchProducts();

      expect(provider.products.length, 6);
      expect(provider.totalCount, 18);
      expect(provider.totalPages, 3);
      expect(provider.currentPage, 1);
      expect(provider.hasPreviousPage, isFalse);
      expect(provider.hasNextPage, isTrue);

      // Go to page 2
      provider.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 2);
      expect(provider.products.length, 6);
      expect(provider.hasPreviousPage, isTrue);
      expect(provider.hasNextPage, isTrue);

      // Go to page 3
      provider.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 3);
      expect(provider.products.length, 6);
      expect(provider.hasNextPage, isFalse);

      // Previous page
      provider.previousPage();
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 2);
    });

    test('Filters products by price range', () async {
      final fake = FakeSupabaseService();
      final provider = ProductProvider(supabaseService: fake);

      // Filter products between $20 and $50 (Items with prices $20, $30, $40, $50 => 4 items)
      provider.updatePriceRange(const RangeValues(20.0, 50.0));
      await Future<void>.delayed(Duration.zero);

      expect(provider.totalCount, 4);
      expect(provider.products.length, 4);
      expect(provider.currentPage, 1);
      expect(provider.totalPages, 1);
    });

    test('Updates and deletes products', () async {
      final fake = FakeSupabaseService();
      final provider = ProductProvider(supabaseService: fake);

      await provider.fetchProducts();

      // Update price of product 1
      final okUpdate = await provider.updateProduct(
        id: 1,
        name: 'Product 1 Updated',
        price: 999.0,
        stock: 5,
      );
      expect(okUpdate, isTrue);

      // Delete product 2
      final okDelete = await provider.deleteProduct(2);
      expect(okDelete, isTrue);
      expect(fake.mockProducts.length, 17);
    });
  });

  group('UI Component Tests', () {
    testWidgets('PriceSliderFilter renders title, slider, and quick chips', (tester) async {
      final provider = ProductProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ProductProvider>.value(
              value: provider,
              child: const PriceSliderFilter(),
            ),
          ),
        ),
      );

      expect(find.text('Price Filter Range'), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Prices'), findsOneWidget);
      expect(find.text('< ₱50'), findsOneWidget);
    });

    testWidgets('PaginationBar displays items summary and page selector when items exist', (tester) async {
      final fake = FakeSupabaseService();
      final provider = ProductProvider(supabaseService: fake);
      await provider.fetchProducts();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ProductProvider>.value(
              value: provider,
              child: const PaginationBar(),
            ),
          ),
        ),
      );

      expect(find.text('Showing 1-6 of 18 items'), findsOneWidget);
      expect(find.text('Per page: '), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('2'), findsWidgets);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('ProductCard displays product details and action buttons', (tester) async {
      const product = Product(
        id: 42,
        name: 'Air Jordan Retro',
        price: 199.99,
        stock: 5,
        description: 'Iconic high-top basketball sneaker.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Air Jordan Retro'), findsOneWidget);
      expect(find.text('₱199.99'), findsOneWidget);
      expect(find.text('5 in stock'), findsOneWidget);
      expect(find.text('#42'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
