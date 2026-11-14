import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';

/// Immutable state for the Enquiry Cart.
class CartState extends Equatable {
  final List<CartItem> items;
  final bool isSubmitting;

  const CartState({
    this.items = const [],
    this.isSubmitting = false,
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
  }) {
    return CartState(
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [items, isSubmitting];
}
