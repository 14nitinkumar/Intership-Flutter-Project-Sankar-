import '../models/product_model.dart';
import '../services/api_service.dart';

/// Repository abstracting product queries and category feeds.
class ProductRepository {
  final ApiService _apiService;

  ProductRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<Product>> fetchProducts({int limit = 20, int skip = 0}) async {
    final response = await _apiService.getProducts(limit: limit, skip: skip);
    final list = response['products'] as List<dynamic>? ?? [];
    return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _apiService.searchProducts(query);
    final list = response['products'] as List<dynamic>? ?? [];
    return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchCategories() async {
    return _apiService.getCategories();
  }

  Future<List<Product>> fetchProductsByCategory(String categorySlug) async {
    final response = await _apiService.getProductsByCategory(categorySlug);
    final list = response['products'] as List<dynamic>? ?? [];
    return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Product> fetchProductDetails(int id) async {
    final response = await _apiService.getProductDetails(id);
    return Product.fromJson(response);
  }
}
