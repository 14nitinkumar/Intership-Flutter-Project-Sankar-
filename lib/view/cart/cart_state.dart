import '../../utils/models/cart_item_model.dart';

class CartState {
  final List<CartItem> items;
  final bool isSubmitting;
  final String? errorMessage;

  CartState({
    this.items = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  int get itemCount => items.length;

  int get totalUnits => items.fold(0, (sum, item) => sum + item.quantity);

  double get estimatedTotal {
    final sum = items.fold(0.0, (total, item) => total + item.subtotal);
    return double.parse(sum.toStringAsFixed(2));
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartState copyWith({
    List<CartItem>? items,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
