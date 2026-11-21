enum ProductSortOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
  nameAZ,
}

class ProductFilter {
  final String search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final ProductSortOption sortOption;

  const ProductFilter({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sortOption = ProductSortOption.newest,
  });

  bool get isActive =>
      search.trim().isNotEmpty ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null ||
      sortOption != ProductSortOption.newest;

  ProductFilter copyWith({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    ProductSortOption? sortOption,
    bool clearCategory = false,
    bool clearPriceRange = false,
  }) {
    return ProductFilter(
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: clearPriceRange ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPriceRange ? null : (maxPrice ?? this.maxPrice),
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
