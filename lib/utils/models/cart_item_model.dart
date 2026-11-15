import 'product_model.dart';

/// Represents an item added to the B2B wholesale enquiry cart.
class CartItem {
  final Product product;
  final int quantity;
  final DateTime addedAt;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  /// The effective price per unit for this order volume based on wholesale tier.
  double get unitPrice => product.wholesaleMeta.getUnitPriceForQuantity(quantity);

  /// Estimated total amount for this item.
  double get subtotal => double.parse((unitPrice * quantity).toStringAsFixed(2));

  CartItem copyWith({
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'addedAt': addedAt.toIso8601String(),
  };
}
