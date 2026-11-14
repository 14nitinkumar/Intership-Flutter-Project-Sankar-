import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

enum SortOption {
  featured,
  priceAsc,
  priceDesc,
  nameAsc,
}

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final SortOption sortOption;

  const ProductLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory,
    this.searchQuery = '',
    this.sortOption = SortOption.featured,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    selectedCategory,
    searchQuery,
    sortOption,
  ];
}

class ProductEmpty extends ProductState {
  final String message;
  final String? selectedCategory;
  final String searchQuery;

  const ProductEmpty({
    required this.message,
    this.selectedCategory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [message, selectedCategory, searchQuery];
}

class ProductFailure extends ProductState {
  final String message;

  const ProductFailure(this.message);

  @override
  List<Object?> get props => [message];
}
