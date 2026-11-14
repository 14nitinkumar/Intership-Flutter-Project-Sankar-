import '../models/cart_item_model.dart';
import '../services/storage_service.dart';

/// Repository abstracting enquiry cart persistence.
class CartRepository {
  final StorageService _storageService;

  CartRepository(this._storageService);

  List<CartItem> loadCartItems() {
    return _storageService.getCartItems();
  }

  Future<void> persistCartItems(List<CartItem> items) async {
    await _storageService.saveCartItems(items);
  }

  Future<void> clearCart() async {
    await _storageService.clearCart();
  }
}
