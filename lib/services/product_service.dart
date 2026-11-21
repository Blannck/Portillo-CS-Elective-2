import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/product_filter.dart';

class ProductService {
  final SupabaseClient _client;

  ProductService(this._client);

  Future<List<Product>> fetchProducts({
    String search = '',
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    ProductSortOption sortOption = ProductSortOption.newest,
  }) async {
    var query = _client.from('products').select();

    final term = search.trim();
    if (term.isNotEmpty) {
      query = query.ilike('name', '%$term%');
    }

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }

    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }

    dynamic data;
    switch (sortOption) {
      case ProductSortOption.newest:
        data = await query.order('created_at', ascending: false);
        break;
      case ProductSortOption.priceLowToHigh:
        data = await query.order('price', ascending: true);
        break;
      case ProductSortOption.priceHighToLow:
        data = await query.order('price', ascending: false);
        break;
      case ProductSortOption.nameAZ:
        data = await query.order('name', ascending: true);
        break;
    }

    return (data as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product?> fetchProductById(int id) async {
    final data = await _client
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return Product.fromJson(data);
  }

  Future<void> addProduct(Product product) async {
    await _client.from('products').insert(product.toJson(includeId: false));
  }

  Future<void> updateProduct(Product product) async {
    final res = await _client
        .from('products')
        .update(product.toJson(includeId: false))
        .eq('id', product.id)
        .select();

    if (res.isEmpty) {
      throw Exception('Product not found or permission denied by RLS');
    }
  }

  Future<void> deleteProduct(int id) async {
    final res = await _client
        .from('products')
        .delete()
        .eq('id', id)
        .select();

    if (res.isEmpty) {
      throw Exception('Product with id $id not found or permission denied');
    }
  }
}
