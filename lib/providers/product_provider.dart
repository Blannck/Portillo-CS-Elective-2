import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';

class ProductProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;

  ProductProvider({SupabaseService? supabaseService})
    : _supabaseService = supabaseService ?? SupabaseService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  static const double minPriceBound = 0.0;
  static const double maxPriceBound = 300.0;
  RangeValues _priceRange = const RangeValues(0.0, 300.0);

  int _currentPage = 1;
  int _pageSize = 6;
  int _totalCount = 0;

  String _searchQuery = '';

  String _sortBy = 'price';
  bool _sortAscending = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RangeValues get priceRange => _priceRange;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalCount => _totalCount;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  int get totalPages {
    if (_totalCount <= 0) return 1;
    return (_totalCount + _pageSize - 1) ~/ _pageSize;
  }

  bool get hasPreviousPage => _currentPage > 1;
  bool get hasNextPage => _currentPage < totalPages;

  Future<void> fetchProducts({bool resetPage = false}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _supabaseService.fetchProducts(
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery,
        sortBy: _sortBy,
        ascending: _sortAscending,
      );

      _products = result.products;
      _totalCount = result.totalCount;

      if (_products.isEmpty && _currentPage > 1 && _totalCount > 0) {
        _currentPage = totalPages;
        await fetchProducts();
        return;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
      _totalCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePriceRange(RangeValues newRange) {
    _priceRange = newRange;
    _currentPage = 1;
    fetchProducts();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    fetchProducts();
  }

  void setPageSize(int size) {
    if (size >= 6 && size <= 8 && size != _pageSize) {
      _pageSize = size;
      _currentPage = 1;
      fetchProducts();
    }
  }

  void nextPage() {
    if (hasNextPage) {
      _currentPage++;
      fetchProducts();
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      fetchProducts();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      fetchProducts();
    }
  }

  void setSorting(String column, bool ascending) {
    _sortBy = column;
    _sortAscending = ascending;
    fetchProducts();
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required double price,
    required int stock,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.updateProduct(id, {
        'name': name,
        'price': price,
        'stock': stock,
        'description': description,
      });
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteProduct(id);
      await fetchProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required int stock,
    int? categoryId,
    String? description,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.insertProduct({
        'name': name,
        'price': price,
        'stock': stock,
        'category_id': categoryId ?? 1,
        'description': description,
        'image_url': imageUrl,
      });
      await fetchProducts(resetPage: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> seedSampleData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.seedInitialProducts();
      await fetchProducts(resetPage: true);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to seed sample data: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
