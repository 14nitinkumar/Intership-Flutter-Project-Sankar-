import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/common_widgets/app_button.dart';
import '../../utils/models/product_model.dart';
import '../cart/cart_cubit.dart';
import 'product_detail_cubit.dart';
import 'product_detail_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product? product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final moq = product.wholesaleMeta.moq;
    final images = product.images.isNotEmpty ? product.images : [product.thumbnail];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Gallery Carousel
            Container(
              height: 280,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (idx) {
                      setState(() => _selectedImageIndex = idx);
                    },
                    itemBuilder: (context, idx) {
                      return Image.network(
                        images[idx],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image_rounded, size: 64, color: AppColors.textMuted),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (idx) {
                          final isCurrent = idx == _selectedImageIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isCurrent ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.actionTeal : AppColors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),

            // Product Information Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & MOQ
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.actionTeal.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Minimum Order: $moq units',
                          style: const TextStyle(
                            color: AppColors.actionTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title & Supplier
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Seller: ${product.wholesaleMeta.supplierLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Wholesale Price Tier Matrix Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.table_chart_outlined, size: 18, color: AppColors.primaryNavy),
                                SizedBox(width: 6),
                                Text(
                                  'Wholesale Volume Pricing Tiers',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Table(
                              border: TableBorder.all(color: AppColors.border),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1.5),
                                2: FlexColumnWidth(1.5),
                              },
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(color: AppColors.background),
                                  children: [
                                    _buildTableHeader('Quantity Bracket'),
                                    _buildTableHeader('Discount'),
                                    _buildTableHeader('Price / Unit'),
                                  ],
                                ),
                                ...product.wholesaleMeta.tierPrices.map((tier) {
                                  final isTierActive = state.quantity >= tier.minQty &&
                                      (tier.maxQty == null || state.quantity <= tier.maxQty!);
                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isTierActive ? AppColors.chipBackground : Colors.white,
                                    ),
                                    children: [
                                      _buildTableCell(tier.label, isBold: isTierActive),
                                      _buildTableCell('${tier.discountPercentage}% OFF',
                                          isBold: isTierActive, color: AppColors.actionTeal),
                                      _buildTableCell('\$${tier.pricePerUnit}',
                                          isBold: isTierActive, color: AppColors.primaryNavy),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Product Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Order Panel
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
            builder: (context, state) {
              return Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () => context.read<ProductDetailCubit>().decrement(),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${state.quantity}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => context.read<ProductDetailCubit>().increment(),
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Total & Add to Enquiry Button
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estimated Total:',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            Text(
                              '\$${state.totalPrice}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppButton(
                          text: 'Add to Enquiry',
                          icon: Icons.add_shopping_cart_rounded,
                          height: 44,
                          onPressed: () {
                            final success = context.read<CartCubit>().addToCart(
                                  product: product,
                                  quantity: state.quantity,
                                );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Added ${state.quantity} units of ${product.title} to enquiry!'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
