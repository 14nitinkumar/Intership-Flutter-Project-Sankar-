import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_state.dart';

/// Cubit responsible for catalog fetching, category filters, keyword search, and sorting.
class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repository;
  List<String> _cachedCategories = [];

  ProductCubit(this._repository) : super(const ProductInitial());

  List<String> get cachedCategories => _cachedCategories;

  /// Fetches categories and default products feed on startup.
  Future<void> loadInitialData() async {
    emit(const ProductLoading());
    try {
      if (_cachedCategories.isEmpty) {
        try {
          _cachedCategories = await _repository.fetchCategories();
        } catch (_) {
          // If categories fail, provide fallback standard wholesale categories
          _cachedCategories = [
            'smartphones',
            'laptops',
            'fragrances',
            'groceries',
            'home-decoration',
            'furniture',
            'tops',
            'lighting',
          ];
        }
      }

      final products = await _repository.fetchProducts(limit: 20);
      if (products.isEmpty) {
        emit(const ProductEmpty(message: 'No wholesale products available.'));
      } else {
        emit(ProductLoaded(
          products: products,
          categories: _cachedCategories,
          selectedCategory: null,
          searchQuery: '',
          sortOption: SortOption.featured,
        ));
      }
    } catch (e) {
      emit(ProductFailure('Unable to load wholesale products: ${e.toString()}'));
    }
  }

  /// Filters products by category. Pass null to reset to All categories.
  Future<void> filterByCategory(String? categorySlug) async {
    emit(const ProductLoading());
    try {
      List<Product> products;
      if (categorySlug == null || categorySlug.isEmpty || categorySlug == 'all') {
        products = await _repository.fetchProducts(limit: 20);
      } else {
        products = await _repository.fetchProductsByCategory(categorySlug);
      }

      if (products.isEmpty) {
        emit(ProductEmpty(
          message: 'No products found in "$categorySlug"',
          selectedCategory: categorySlug,
        ));
      } else {
        emit(ProductLoaded(
          products: _applySorting(products, SortOption.featured),
          categories: _cachedCategories,
          selectedCategory: (categorySlug == 'all') ? null : categorySlug,
          searchQuery: '',
          sortOption: SortOption.featured,
        ));
      }
    } catch (e) {
      emit(ProductFailure('Failed to load category products: ${e.toString()}'));
    }
  }

  /// Searches products by keyword.
  Future<void> searchProducts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return filterByCategory(null);
    }

    emit(const ProductLoading());
    try {
      final products = await _repository.searchProducts(trimmed);
      if (products.isEmpty) {
        emit(ProductEmpty(
          message: 'No wholesale matches found for "$trimmed"',
          searchQuery: trimmed,
        ));
      } else {
        emit(ProductLoaded(
          products: _applySorting(products, SortOption.featured),
          categories: _cachedCategories,
          selectedCategory: null,
          searchQuery: trimmed,
          sortOption: SortOption.featured,
        ));
      }
    } catch (e) {
      emit(ProductFailure('Search failed: ${e.toString()}'));
    }
  }

  /// Sorts currently loaded products.
  void setSortOption(SortOption sortOption) {
    if (state is ProductLoaded) {
      final current = state as ProductLoaded;
      final sorted = _applySorting(List.from(current.products), sortOption);
      emit(current.copyWith(
        products: sorted,
        sortOption: sortOption,
      ));
    }
  }

  List<Product> _applySorting(List<Product> list, SortOption option) {
    final copy = List<Product>.from(list);
    switch (option) {
      case SortOption.priceAsc:
        copy.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        copy.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAsc:
        copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.featured:
        // Keep standard server ranking
        break;
    }
    return copy;
  }
}
