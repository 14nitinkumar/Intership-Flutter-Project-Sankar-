import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/empty_state_view.dart';
import '../common_widgets/error_state_view.dart';
import '../common_widgets/product_card.dart';
import '../core/app_colors.dart';
import '../data/models/product_model.dart';
import '../logic/cart/cart_cubit.dart';
import '../logic/cart/cart_state.dart';
import '../logic/product/product_cubit.dart';
import '../logic/product/product_state.dart';

// =============================================================================
// SCREEN 3 OF 3: PRODUCT SCREEN (PRODUCT LISTING & PRODUCT DETAILS)
// =============================================================================

/// Product Listing Screen with search, category filtering, and sorting.
class ProductListingScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialQuery;

  const ProductListingScreen({
    super.key,
    this.initialCategory,
    this.initialQuery,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String? categorySlug) {
    _searchController.clear();
    context.read<ProductCubit>().filterByCategory(categorySlug);
  }

  void _onSearchSubmitted(String query) {
    context.read<ProductCubit>().searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Catalog'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: cartState.itemCount > 0,
                  label: Text('${cartState.itemCount}'),
                  backgroundColor: AppColors.actionTeal,
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ),
                tooltip: 'Enquiry Cart',
                onPressed: () {
                  context.go('/dashboard', extra: 1);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Controls Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onSubmitted: _onSearchSubmitted,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search products by title, category, or keyword...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductCubit>().filterByCategory(null);
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips and Sorting Row
                Row(
                  children: [
                    // Horizontal Category Chips List
                    Expanded(
                      child: BlocBuilder<ProductCubit, ProductState>(
                        builder: (context, state) {
                          final categories = context.read<ProductCubit>().cachedCategories;
                          final selectedCategory = state is ProductLoaded ? state.selectedCategory : null;

                          return SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ChoiceChip(
                                  label: const Text('ALL'),
                                  selected: selectedCategory == null,
                                  selectedColor: AppColors.actionTeal,
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selectedCategory == null ? Colors.white : AppColors.primaryNavy,
                                  ),
                                  onSelected: (_) => _onCategorySelected(null),
                                ),
                                const SizedBox(width: 6),
                                ...categories.map((cat) {
                                  final isSelected = selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(cat.replaceAll('-', ' ').toUpperCase()),
                                      selected: isSelected,
                                      selectedColor: AppColors.actionTeal,
                                      labelStyle: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : AppColors.primaryNavy,
                                      ),
                                      onSelected: (_) => _onCategorySelected(cat),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Sort Menu
                    BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, state) {
                        final currentSort = state is ProductLoaded ? state.sortOption : SortOption.featured;

                        return PopupMenuButton<SortOption>(
                          icon: const Icon(Icons.sort_rounded, color: AppColors.primaryNavy),
                          tooltip: 'Sort by',
                          initialValue: currentSort,
                          onSelected: (option) => context.read<ProductCubit>().setSortOption(option),
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: SortOption.featured,
                              child: Text('Featured'),
                            ),
                            PopupMenuItem(
                              value: SortOption.priceAsc,
                              child: Text('Price: Low to High'),
                            ),
                            PopupMenuItem(
                              value: SortOption.priceDesc,
                              child: Text('Price: High to Low'),
                            ),
                            PopupMenuItem(
                              value: SortOption.nameAsc,
                              child: Text('Name: A to Z'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Listing Grid
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.actionTeal),
                  );
                }

                if (state is ProductFailure) {
                  return ErrorStateView(
                    message: state.message,
                    onRetry: () => context.read<ProductCubit>().loadInitialData(),
                  );
                }

                if (state is ProductEmpty) {
                  return EmptyStateView(
                    title: 'No Products Found',
                    message: state.message,
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      context.read<ProductCubit>().filterByCategory(null);
                    },
                  );
                }

                if (state is ProductLoaded) {
                  return RefreshIndicator(
                    onRefresh: () => context.read<ProductCubit>().loadInitialData(),
                    color: AppColors.actionTeal,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.70,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push('/details', extra: product),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Product Details Screen with MOQ, bulk wholesale price tier table, and enquiry cart addition.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    // Default quantity begins at the Minimum Order Quantity (MOQ)
    _quantity = widget.product.wholesaleMeta.moq;
  }

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > widget.product.wholesaleMeta.moq) {
      setState(() {
        _quantity--;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum Order Quantity for this product is ${widget.product.wholesaleMeta.moq} units.'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addToCart() {
    final success = context.read<CartCubit>().addToCart(
      product: widget.product,
      quantity: _quantity,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity units to your Enquiry Cart!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.go('/dashboard', extra: 1);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final meta = product.wholesaleMeta;
    final currentUnitPrice = meta.getUnitPriceForQuantity(_quantity);
    final totalAmount = double.parse((currentUnitPrice * _quantity).toStringAsFixed(2));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Product Overview'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: cartState.itemCount > 0,
                  label: Text('${cartState.itemCount}'),
                  backgroundColor: AppColors.actionTeal,
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ),
                tooltip: 'Enquiry Cart',
                onPressed: () {
                  context.go('/dashboard', extra: 1);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Preview
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.white,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                ),
              ),
            ),
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Supplier Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.actionTeal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          meta.supplierLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating & Stock
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Stock: ${product.stock} units available',
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Wholesale Minimum Order Quantity Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                              children: [
                                const TextSpan(text: 'Minimum Order Quantity (MOQ): '),
                                TextSpan(
                                  text: '${meta.moq} units',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.actionTeal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Wholesale Price Tiers Table
                  const Text(
                    'Wholesale Bulk Pricing Tiers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Order in higher bulk volumes to unlock wholesale price reductions.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),

                  // Tiers Table Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          // Table Header
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text('TIER VOLUME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('DISCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                                Expanded(flex: 2, child: Text('UNIT PRICE', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                              ],
                            ),
                          ),
                          const Divider(height: 8),

                          // Table Rows
                          ...meta.tierPrices.map((tier) {
                            final isCurrentTier = _quantity >= tier.minQty && (tier.maxQty == null || _quantity <= tier.maxQty!);

                            return Container(
                              color: isCurrentTier ? AppColors.chipBackground.withValues(alpha: 0.5) : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        if (isCurrentTier) ...[
                                          const Icon(Icons.check_circle, size: 14, color: AppColors.actionTeal),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          tier.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isCurrentTier ? FontWeight.w800 : FontWeight.w600,
                                            color: isCurrentTier ? AppColors.actionTeal : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${tier.discountPercentage}% OFF',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrentTier ? AppColors.actionTeal : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '\$${tier.pricePerUnit}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isCurrentTier ? FontWeight.w800 : FontWeight.w700,
                                        color: isCurrentTier ? AppColors.actionTeal : AppColors.primaryNavy,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Order Action Panel
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
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
                      onPressed: _decrement,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _increment,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Total & Add Button
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
                          '\$$totalAmount',
                          style: const TextStyle(
                            fontSize: 15,
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
                      onPressed: _addToCart,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
