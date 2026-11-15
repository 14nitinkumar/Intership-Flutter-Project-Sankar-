import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../main.dart';
import '../../utils/models/cart_item_model.dart';
import '../../utils/models/product_model.dart';
import '../../utils/preference_keys/preference_keys.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState()) {
    loadCart();
  }

  void loadCart() {
    final jsonStr = sharedPreferences.getString(PreferenceKeys.cartItems);
    if (jsonStr == null || jsonStr.isEmpty) {
      emit(state.copyWith(items: []));
      return;
    }
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      final items = list
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(items: items));
    } catch (_) {
      emit(state.copyWith(items: []));
    }
  }

  bool addToCart({required Product product, required int quantity}) {
    if (quantity < product.wholesaleMeta.moq) {
      return false;
    }

    final currentItems = List<CartItem>.from(state.items);
    final existingIndex =
        currentItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final existing = currentItems[existingIndex];
      final newQty = existing.quantity + quantity;
      currentItems[existingIndex] = existing.copyWith(quantity: newQty);
    } else {
      currentItems.add(CartItem(
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      ));
    }

    _persistCart(currentItems);
    emit(state.copyWith(items: currentItems));
    return true;
  }

  bool updateQuantity({required int productId, required int newQuantity}) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);

    if (index < 0) return false;

    final item = currentItems[index];
    if (newQuantity < item.product.wholesaleMeta.moq) {
      return false;
    }

    currentItems[index] = item.copyWith(quantity: newQuantity);
    _persistCart(currentItems);
    emit(state.copyWith(items: currentItems));
    return true;
  }

  void removeItem(int productId) {
    final currentItems = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.product.id == productId);

    _persistCart(currentItems);
    emit(state.copyWith(items: currentItems));
  }

  Future<void> clearCart() async {
    await sharedPreferences.remove(PreferenceKeys.cartItems);
    emit(state.copyWith(items: []));
  }

  Future<void> _persistCart(List<CartItem> items) async {
    final list = items.map((item) => item.toJson()).toList();
    await sharedPreferences.setString(PreferenceKeys.cartItems, jsonEncode(list));
  }
}
