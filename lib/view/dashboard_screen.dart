import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../common_widgets/app_button.dart';
import '../common_widgets/app_text_field.dart';
import '../common_widgets/empty_state_view.dart';
import '../common_widgets/error_state_view.dart';
import '../common_widgets/product_card.dart';
import '../core/app_colors.dart';
import '../data/models/product_model.dart';
import '../logic/auth/auth_cubit.dart';
import '../logic/auth/auth_state.dart';
import '../logic/cart/cart_cubit.dart';
import '../logic/cart/cart_state.dart';
import '../logic/enquiry/enquiry_cubit.dart';
import '../logic/enquiry/enquiry_state.dart';
import '../logic/product/product_cubit.dart';
import '../logic/product/product_state.dart';

// =============================================================================
// SCREEN 2 OF 3: DASHBOARD SCREEN (HOME, ENQUIRY CART, PROFILE / HISTORY)
// =============================================================================

/// The central shell view containing the Bottom Navigation Bar and 3 primary tabs.
class DashboardScreen extends StatefulWidget {
  final int initialTab;

  const DashboardScreen({super.key, this.initialTab = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;
  final TextEditingController _buyerNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().loadInitialData();
      context.read<EnquiryCubit>().loadHistory();
    });
  }

  @override
  void dispose() {
    _buyerNoteController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _HomeTab(onNavigateToListing: () => context.push('/listing')),
              _CartTab(
                buyerNoteController: _buyerNoteController,
                onGoToHistory: () => setState(() => _currentIndex = 2),
                onBrowseProducts: () => context.push('/listing'),
              ),
              const _HistoryProfileTab(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.chipBackground,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.actionTeal),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartState.itemCount > 0,
                    label: Text('${cartState.itemCount}'),
                    backgroundColor: AppColors.actionTeal,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartState.itemCount > 0,
                    label: Text('${cartState.itemCount}'),
                    backgroundColor: AppColors.actionTeal,
                    child: const Icon(Icons.shopping_cart, color: AppColors.actionTeal),
                  ),
                  label: 'Enquiry Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long, color: AppColors.actionTeal),
                  label: 'Enquiries',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// TAB 1: HOME VIEW
// =============================================================================
class _HomeTab extends StatelessWidget {
  final VoidCallback onNavigateToListing;

  const _HomeTab({required this.onNavigateToListing});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is AuthAuthenticated ? authState.user.displayName : 'Buyer';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<ProductCubit>().loadInitialData(),
        color: AppColors.actionTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good day, $userName 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Discover bulk wholesale deals',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onNavigateToListing,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.chipBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: AppColors.actionTeal,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar Shortcut
              InkWell(
                onTap: onNavigateToListing,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 20, color: AppColors.textMuted),
                      SizedBox(width: 10),
                      Text(
                        'Search wholesale products or categories...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hero Promotional Wholesale Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryNavy, Color(0xFF2C3E50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.actionTeal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'WHOLESALE HUB',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Source smarter. Buy in bulk.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tiered bulk discounts directly from verified trade suppliers.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Category Shortcuts Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Browse Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToListing,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.actionTeal,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: const Text('View All ›'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Chips Carousel
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  final categories = context.read<ProductCubit>().cachedCategories;
                  if (categories.isEmpty) {
                    return const SizedBox(height: 38);
                  }

                  return SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length.clamp(0, 8),
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ActionChip(
                          label: Text(
                            cat.replaceAll('-', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onPressed: () {
                            context.read<ProductCubit>().filterByCategory(cat);
                            context.push('/listing');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),

              // Featured Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Wholesale Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToListing,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.actionTeal,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: const Text('See More ›'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Product Grid / Feed
              BlocBuilder<ProductCubit, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: AppColors.actionTeal),
                      ),
                    );
                  }

                  if (state is ProductFailure) {
                    return ErrorStateView(
                      message: state.message,
                      onRetry: () => context.read<ProductCubit>().loadInitialData(),
                    );
                  }

                  if (state is ProductLoaded) {
                    final products = state.products.take(6).toList();
                    if (products.isEmpty) {
                      return const EmptyStateView(
                        title: 'No Products',
                        message: 'Check back soon for wholesale listings.',
                      );
                    }

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push('/details', extra: product),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TAB 2: ENQUIRY CART VIEW
// =============================================================================
class _CartTab extends StatelessWidget {
  final TextEditingController buyerNoteController;
  final VoidCallback onGoToHistory;
  final VoidCallback onBrowseProducts;

  const _CartTab({
    required this.buyerNoteController,
    required this.onGoToHistory,
    required this.onBrowseProducts,
  });

  void _confirmRemoveItem(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Remove from Enquiry?'),
          content: Text('Remove "${product.title}" from your wholesale enquiry cart?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<CartCubit>().removeItem(product.id);
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item removed from enquiry cart'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _submitEnquiry(BuildContext context, CartState cartState) async {
    final enquiryCubit = context.read<EnquiryCubit>();
    final cartCubit = context.read<CartCubit>();

    final success = await enquiryCubit.submitEnquiry(
      items: cartState.items,
      buyerNote: buyerNoteController.text,
    );

    if (!context.mounted || !success) return;
    buyerNoteController.clear();
    await cartCubit.clearCart();
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle_outline, color: AppColors.actionTeal, size: 48),
          title: const Text('Enquiry Submitted!'),
          content: const Text(
            'Your wholesale enquiry has been recorded successfully. Verified suppliers will review your requested bulk tiers.',
          ),
          actions: [
            AppButton(
              text: 'View Enquiry Records',
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                onGoToHistory();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquiry Cart'),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return EmptyStateView(
              icon: Icons.remove_shopping_cart_outlined,
              title: 'Your Enquiry Cart is Empty',
              message: 'Add items with required minimum order quantities to generate a bulk enquiry.',
              buttonText: 'Browse Catalog',
              onButtonPressed: onBrowseProducts,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final moq = item.product.wholesaleMeta.moq;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.thumbnail,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 70,
                                  height: 70,
                                  color: AppColors.background,
                                  child: const Icon(Icons.inventory_2_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Item Details & Controls
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.product.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _confirmRemoveItem(context, item.product),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unit Price: \$${item.unitPrice} (MOQ: $moq)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 8),

                                  // Quantity Selector + Subtotal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity Adjuster
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.border),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: item.quantity > moq
                                                  ? () {
                                                      context.read<CartCubit>().updateQuantity(
                                                            productId: item.product.id,
                                                            newQuantity: item.quantity - 1,
                                                          );
                                                    }
                                                  : () {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Minimum order is $moq units'),
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    },
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 16,
                                                  color: item.quantity > moq ? AppColors.textPrimary : AppColors.textMuted,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                context.read<CartCubit>().updateQuantity(
                                                      productId: item.product.id,
                                                      newQuantity: item.quantity + 1,
                                                    );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                child: Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Subtotal
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Summary & Submission Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Buyer Note
                      AppTextField(
                        controller: buyerNoteController,
                        hintText: 'Add delivery or packaging note (optional)...',
                        maxLines: 1,
                        prefixIcon: Icons.edit_note_rounded,
                      ),
                      const SizedBox(height: 12),

                      // Totals Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.itemCount} items (${state.totalUnits} total units)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                              const Text(
                                'Estimated Wholesale:',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ],
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
                      const SizedBox(height: 14),

                      // Submit CTA
                      AppButton(
                        text: 'Submit Bulk Enquiry',
                        icon: Icons.send_rounded,
                        onPressed: () => _submitEnquiry(context, state),
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

// =============================================================================
// TAB 3: ENQUIRY HISTORY & PROFILE VIEW
// =============================================================================
class _HistoryProfileTab extends StatelessWidget {
  const _HistoryProfileTab();

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Sign Out?'),
          content: const Text('Are you sure you want to sign out? Your saved wholesale enquiries will be preserved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<AuthCubit>().logout();
                context.go('/auth');
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquiries & Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
      body: BlocBuilder<EnquiryCubit, EnquiryState>(
        builder: (context, enquiryState) {
          final enquiries = enquiryState is EnquiryLoaded ? enquiryState.enquiries : <dynamic>[];

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EnquiryCubit>().loadHistory();
            },
            color: AppColors.actionTeal,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryNavy,
                          child: Text(
                            user != null && user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'B',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'Verified Buyer',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'buyer@vyapaarhub.com',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.chipBackground,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '✓ Verified Wholesale Buyer',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.actionTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enquiry History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Text(
                      '${enquiries.length} submitted',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Enquiry History List
                if (enquiryState is EnquiryLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.actionTeal),
                    ),
                  )
                else if (enquiries.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.history_rounded, size: 40, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No enquiries placed yet',
                              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Items submitted from your Enquiry Cart will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...enquiries.map((enq) {
                    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(enq.createdAt);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID and Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  enq.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryNavy,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBackground,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    enq.status,
                                    style: const TextStyle(
                                      color: AppColors.actionTeal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateFormatted,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const Divider(height: 16),

                            // Products Summary
                            ...enq.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Text('• ', style: TextStyle(color: AppColors.actionTeal)),
                                    Expanded(
                                      child: Text(
                                        '${item.product.title} (${item.quantity} units @ \$${item.unitPrice})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    Text(
                                      '\$${item.subtotal}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            if (enq.buyerNote.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Note: "${enq.buyerNote}"',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ${enq.totalQuantity} units',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                                ),
                                Text(
                                  'Est. Value: \$${enq.totalEstimatedAmount}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),
                AppButton(
                  text: 'Sign Out Account',
                  type: ButtonType.destructive,
                  icon: Icons.logout_rounded,
                  onPressed: () => _confirmSignOut(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
