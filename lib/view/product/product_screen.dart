import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../utils/common_widgets/empty_state_view.dart';
import '../../utils/common_widgets/error_state_view.dart';
import '../../utils/common_widgets/product_card.dart';
import '../../utils/routes/routes.dart';
import '../../utils/app_colors.dart';
import 'product_cubit.dart';
import 'product_state.dart';

class ProductScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const ProductScreen({
    super.key,
    this.initialQuery,
    this.initialCategory,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null) {
        context.read<ProductCubit>().filterByCategory(widget.initialCategory);
      } else if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        context.read<ProductCubit>().searchProducts(widget.initialQuery!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortModal(BuildContext context, SortOption currentSort) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Wholesale Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded),
                  title: const Text('Featured / Relevance'),
                  trailing: currentSort == SortOption.featured
                      ? const Icon(Icons.check, color: AppColors.actionTeal)
                      : null,
                  onTap: () {
                    context.read<ProductCubit>().setSortOption(SortOption.featured);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward_rounded),
                  title: const Text('Price: Low to High'),
                  trailing: currentSort == SortOption.priceAsc
                      ? const Icon(Icons.check, color: AppColors.actionTeal)
                      : null,
                  onTap: () {
                    context.read<ProductCubit>().setSortOption(SortOption.priceAsc);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded),
                  title: const Text('Price: High to Low'),
                  trailing: currentSort == SortOption.priceDesc
                      ? const Icon(Icons.check, color: AppColors.actionTeal)
                      : null,
                  onTap: () {
                    context.read<ProductCubit>().setSortOption(SortOption.priceDesc);
                    Navigator.pop(sheetContext);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded),
                  title: const Text('Product Name: A to Z'),
                  trailing: currentSort == SortOption.nameAsc
                      ? const Icon(Icons.check, color: AppColors.actionTeal)
                      : null,
                  onTap: () {
                    context.read<ProductCubit>().setSortOption(SortOption.nameAsc);
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Catalog'),
        actions: [
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Sort & Filter',
                onPressed: () => _showSortModal(context, state.sortOption),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search wholesale items, suppliers...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            onSubmitted: (value) {
                              context.read<ProductCubit>().searchProducts(value);
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductCubit>().filterByCategory(null);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories Horizontal List
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state.categories.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 48,
                color: Colors.white,
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.categories.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll ? 'all' : state.categories[index - 1];
                    final isSelected = isAll
                        ? (state.selectedCategory == null)
                        : (state.selectedCategory == category);

                    return ChoiceChip(
                      label: Text(
                        isAll ? 'All Categories' : category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryNavy,
                      backgroundColor: AppColors.background,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryNavy : AppColors.border,
                      ),
                      onSelected: (_) {
                        context.read<ProductCubit>().filterByCategory(isAll ? null : category);
                      },
                    );
                  },
                ),
              );
            },
          ),

          // Product Grid or States
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.actionTeal),
                    ),
                  );
                }

                if (state.errorMessage != null) {
                  return ErrorStateView(
                    message: state.errorMessage!,
                    onRetry: () => context.read<ProductCubit>().loadInitialData(),
                  );
                }

                if (state.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Wholesale Matches',
                    message: state.searchQuery.isNotEmpty
                        ? 'No products found matching "${state.searchQuery}". Try different keywords.'
                        : 'No wholesale items in this category yet.',
                    buttonText: 'Show All Products',
                    onButtonPressed: () {
                      _searchController.clear();
                      context.read<ProductCubit>().filterByCategory(null);
                    },
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        context.push(
                          AppRouter.productDetailScreen,
                          extra: product,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
