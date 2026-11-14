import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Handles HTTP REST API requests to DummyJSON endpoints.
class ApiService {
  final http.Client _client;
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 15);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches products with pagination.
  Future<Map<String, dynamic>> getProducts({int limit = 20, int skip = 0}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    return _get(uri);
  }

  /// Searches products by keyword.
  Future<Map<String, dynamic>> searchProducts(String query) async {
    final uri = Uri.parse('$_baseUrl/products/search?q=${Uri.encodeComponent(query)}');
    return _get(uri);
  }

  /// Fetches list of categories.
  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$_baseUrl/products/category-list');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) {
            if (e is Map && e.containsKey('slug')) {
              return e['slug'].toString();
            }
            return e.toString();
          }).toList();
        }
      }
      throw ApiException('Failed to load categories (Status: ${response.statusCode})');
    } on SocketException {
      throw const ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching categories: $e');
    }
  }

  /// Fetches products by category slug.
  Future<Map<String, dynamic>> getProductsByCategory(String categorySlug) async {
    final uri = Uri.parse('$_baseUrl/products/category/${Uri.encodeComponent(categorySlug)}');
    return _get(uri);
  }

  /// Fetches a single product by ID.
  Future<Map<String, dynamic>> getProductDetails(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    return _get(uri);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw ApiException('Server error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on SocketException {
      throw const ApiException('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw const ApiException('Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
