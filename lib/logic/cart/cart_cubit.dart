import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

/// Cubit managing Enquiry Cart item addition, volume tier updates, and persistence.
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(const CartState()) {
    loadCart();
  }

  /// Loads saved cart items from storage.
  void loadCart() {
    final items = _repository.loadCartItems();
    emit(state.copyWith(items: items));
  }

  /// Adds a product to the cart with MOQ enforcement.
  bool addToCart({required Product product, required int quantity}) {
    if (quantity < product.wholesaleMeta.moq) {
      return false;
    }

    final currentItems = List<CartItem>.from(state.items);
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

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

    _repository.persistCartItems(currentItems);
    emit(state.copyWith(items: currentItems));
    return true;
  }

  /// Updates quantity for a specific product, ensuring it does not drop below MOQ.
  bool updateQuantity({required int productId, required int newQuantity}) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere((item) => item.product.id == productId);

    if (index < 0) return false;

    final item = currentItems[index];
    if (newQuantity < item.product.wholesaleMeta.moq) {
      return false;
    }

    currentItems[index] = item.copyWith(quantity: newQuantity);
    _repository.persistCartItems(currentItems);
    emit(state.copyWith(items: currentItems));
    return true;
  }

  /// Removes an item from the cart.
  void removeItem(int productId) {
    final currentItems = List<CartItem>.from(state.items)
      ..removeWhere((item) => item.product.id == productId);

    _repository.persistCartItems(currentItems);
    emit(state.copyWith(items: currentItems));
  }

  /// Clears the entire enquiry cart upon successful enquiry submission.
  Future<void> clearCart() async {
    await _repository.clearCart();
    emit(state.copyWith(items: []));
  }
}
