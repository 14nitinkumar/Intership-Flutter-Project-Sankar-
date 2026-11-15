import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/models/product_model.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final Product? product;

  ProductDetailCubit({this.product})
      : super(ProductDetailState(
          quantity: product?.wholesaleMeta.moq ?? 10,
          unitPrice: product != null
              ? product.wholesaleMeta.getUnitPriceForQuantity(product.wholesaleMeta.moq)
              : 0.0,
          totalPrice: product != null
              ? double.parse(
                  (product.wholesaleMeta.getUnitPriceForQuantity(product.wholesaleMeta.moq) *
                          product.wholesaleMeta.moq)
                      .toStringAsFixed(2),
                )
              : 0.0,
        ));

  void increment() {
    if (product == null) return;
    final newQty = state.quantity + 1;
    _updateStateForQty(newQty);
  }

  void decrement() {
    if (product == null) return;
    final moq = product!.wholesaleMeta.moq;
    if (state.quantity <= moq) return;
    final newQty = state.quantity - 1;
    _updateStateForQty(newQty);
  }

  void setQuantity(int qty) {
    if (product == null) return;
    final moq = product!.wholesaleMeta.moq;
    final actual = qty < moq ? moq : qty;
    _updateStateForQty(actual);
  }

  void _updateStateForQty(int qty) {
    final unitPrice = product!.wholesaleMeta.getUnitPriceForQuantity(qty);
    final total = double.parse((unitPrice * qty).toStringAsFixed(2));
    emit(state.copyWith(
      quantity: qty,
      unitPrice: unitPrice,
      totalPrice: total,
    ));
  }
}
