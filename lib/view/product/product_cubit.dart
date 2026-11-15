import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/models/product_model.dart';
import '../../utils/network_class/api_url_constants.dart';
import '../../utils/network_class/dio_network_class.dart';
import '../../utils/network_class/network_response.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> implements NetworkResponse {
  List<String> _cachedCategories = [];

  ProductCubit() : super(ProductState()) {
    loadInitialData();
  }

  List<String> get cachedCategories => _cachedCategories;

  void loadInitialData() {
    emit(state.copyWith(isLoading: true, clearError: true));
    if (_cachedCategories.isEmpty) {
      DioNetworkClass(
        networkResponse: this,
        endUrl: getCategoriesUrl,
        requestCode: getCategoriesReq,
      ).callRequestServiceHeader(false, "get");
    }

    DioNetworkClass.fromNetworkClass(
      networkResponse: this,
      endUrl: getProductsUrl,
      requestCode: getProductsReq,
      jsonBody: {'limit': 20, 'skip': 0},
    ).callRequestServiceHeader(false, "get");
  }

  void filterByCategory(String? categorySlug) {
    emit(state.copyWith(
      isLoading: true,
      selectedCategory: (categorySlug == null || categorySlug.isEmpty || categorySlug == 'all') ? null : categorySlug,
      clearCategory: (categorySlug == null || categorySlug.isEmpty || categorySlug == 'all'),
      searchQuery: '',
      clearError: true,
    ));

    if (categorySlug == null || categorySlug.isEmpty || categorySlug == 'all') {
      DioNetworkClass.fromNetworkClass(
        networkResponse: this,
        endUrl: getProductsUrl,
        requestCode: getProductsReq,
        jsonBody: {'limit': 20, 'skip': 0},
      ).callRequestServiceHeader(false, "get");
    } else {
      DioNetworkClass(
        networkResponse: this,
        endUrl: "$getProductsByCategoryUrl$categorySlug",
        requestCode: getProductsByCategoryReq,
      ).callRequestServiceHeader(false, "get");
    }
  }

  void searchProducts(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      filterByCategory(null);
      return;
    }

    emit(state.copyWith(
      isLoading: true,
      searchQuery: trimmed,
      clearCategory: true,
      clearError: true,
    ));

    DioNetworkClass.fromNetworkClass(
      networkResponse: this,
      endUrl: searchProductsUrl,
      requestCode: searchProductsReq,
      jsonBody: {'q': trimmed},
    ).callRequestServiceHeader(false, "get");
  }

  void setSortOption(SortOption sortOption) {
    final sorted = _applySorting(List.from(state.products), sortOption);
    emit(state.copyWith(
      products: sorted,
      sortOption: sortOption,
    ));
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
        break;
    }
    return copy;
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      log("ProductCubit onResponse: req=$requestCode");
      switch (requestCode) {
        case getCategoriesReq:
          final decoded = jsonDecode(response);
          if (decoded is List) {
            _cachedCategories = decoded.map((e) {
              if (e is Map && e.containsKey('slug')) {
                return e['slug'].toString();
              }
              return e.toString();
            }).toList();
            emit(state.copyWith(categories: _cachedCategories));
          }
          break;

        case getProductsReq:
        case getProductsByCategoryReq:
        case searchProductsReq:
          final map = jsonDecode(response) as Map<String, dynamic>;
          final list = map['products'] as List<dynamic>? ?? [];
          final products = list
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

          final sorted = _applySorting(products, state.sortOption);
          emit(state.copyWith(
            products: sorted,
            categories: _cachedCategories,
            isLoading: false,
            clearError: true,
          ));
          break;
      }
    } catch (e, st) {
      debugPrint("ProductCubit onResponse error: $e\n$st");
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Failed to parse products response.",
      ));
    }
  }

  @override
  void onApiError({required int requestCode, required String response}) {
    try {
      debugPrint("ProductCubit onApiError: $requestCode: $response");
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Network error loading wholesale products.",
      ));
    } catch (e) {
      debugPrint("Exception in onApiError: $e");
    }
  }
}
