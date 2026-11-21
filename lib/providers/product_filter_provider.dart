import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_filter.dart';

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() {
    return const ProductFilter();
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }

  void setCategoryId(int? categoryId) {
    if (state.categoryId == categoryId) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void setSortOption(ProductSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void reset() {
    state = const ProductFilter();
  }
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);
