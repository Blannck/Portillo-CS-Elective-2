import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_filter_provider.dart';
import 'supabase_provider.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService(ref.watch(supabaseProvider));
});

class ProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    final filter = ref.watch(productFilterProvider);
    return ref.read(productServiceProvider).fetchProducts(
          search: filter.search,
          categoryId: filter.categoryId,
          minPrice: filter.minPrice,
          maxPrice: filter.maxPrice,
          sortOption: filter.sortOption,
        );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final filter = ref.read(productFilterProvider);
    state = await AsyncValue.guard(
      () => ref.read(productServiceProvider).fetchProducts(
            search: filter.search,
            categoryId: filter.categoryId,
            minPrice: filter.minPrice,
            maxPrice: filter.maxPrice,
            sortOption: filter.sortOption,
          ),
    );
  }

  Future<void> addProduct(Product product) async {
    await ref.read(productServiceProvider).addProduct(product);
    await refresh();
  }

  Future<void> updateProduct(Product product) async {
    await ref.read(productServiceProvider).updateProduct(product);
    await refresh();
  }

  Future<void> deleteProduct(int id) async {
    await ref.read(productServiceProvider).deleteProduct(id);
    final currentProducts = state.value ?? [];
    state = AsyncData(currentProducts.where((p) => p.id != id).toList());
  }
}

final productProvider = AsyncNotifierProvider<ProductNotifier, List<Product>>(
  ProductNotifier.new,
);
