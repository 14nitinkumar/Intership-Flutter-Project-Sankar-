import '../../utils/models/product_model.dart';

enum SortOption {
  featured,
  priceAsc,
  priceDesc,
  nameAsc,
}

class ProductState {
  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final SortOption sortOption;
  final bool isLoading;
  final String? errorMessage;

  ProductState({
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = SortOption.featured,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && products.isEmpty;

  ProductState copyWith({
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    SortOption? sortOption,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
