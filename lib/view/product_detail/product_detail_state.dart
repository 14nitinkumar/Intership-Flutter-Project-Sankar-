class ProductDetailState {
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  ProductDetailState({
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  ProductDetailState copyWith({
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return ProductDetailState(
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
