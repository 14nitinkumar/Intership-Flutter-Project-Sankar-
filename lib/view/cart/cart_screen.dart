import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/common_widgets/app_button.dart';
import '../../utils/common_widgets/empty_state_view.dart';
import '../enquiry/enquiry_cubit.dart';
import 'cart_cubit.dart';
import 'cart_state.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBrowseProducts;

  const CartScreen({
    super.key,
    this.onBrowseProducts,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitEnquiry(BuildContext context, CartState state) async {
    final enquiryCubit = context.read<EnquiryCubit>();
    final cartCubit = context.read<CartCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await enquiryCubit.submitEnquiry(
      items: state.items,
      buyerNote: _noteController.text,
    );

    if (success && mounted) {
      await cartCubit.clearCart();
      _noteController.clear();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Wholesale enquiry successfully submitted to suppliers!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Enquiry Cart'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear Cart',
                onPressed: () {
                  context.read<CartCubit>().clearCart();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your Enquiry Cart is Empty',
              message: 'Add bulk products with required minimum order quantities to request an official wholesale quotation.',
              buttonText: 'Browse Catalog',
              onButtonPressed: widget.onBrowseProducts ?? () => Navigator.maybePop(context),
            );
          }

          return Column(
            children: [
              // Notice banner
              Container(
                color: AppColors.chipBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.actionTeal),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tier discounts applied automatically based on total unit volume.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.actionTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final product = item.product;
                    final moq = product.wholesaleMeta.moq;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.thumbnail,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.background,
                                child: const Icon(Icons.broken_image_outlined, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MOQ: $moq units • \$${item.unitPrice}/unit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity Stepper
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 16),
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            padding: EdgeInsets.zero,
                                            onPressed: item.quantity > moq
                                                ? () {
                                                    context.read<CartCubit>().updateQuantity(
                                                          productId: product.id,
                                                          newQuantity: item.quantity - 1,
                                                        );
                                                  }
                                                : null,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 16),
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              context.read<CartCubit>().updateQuantity(
                                                    productId: product.id,
                                                    newQuantity: item.quantity + 1,
                                                  );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${item.subtotal}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              context.read<CartCubit>().removeItem(product.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Order Request Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Add remarks for seller (e.g. GST billing, urgent)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.totalUnits} Units (${state.itemCount} Items)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              Text(
                                '\$${state.estimatedTotal}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 180,
                            child: AppButton(
                              text: 'Request Quote',
                              icon: Icons.send_rounded,
                              height: 46,
                              onPressed: () => _submitEnquiry(context, state),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
