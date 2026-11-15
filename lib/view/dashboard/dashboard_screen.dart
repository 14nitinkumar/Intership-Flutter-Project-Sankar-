import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../utils/common_widgets/app_button.dart';
import '../../utils/routes/routes.dart';
import '../../utils/app_colors.dart';
import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';
import '../cart/cart_cubit.dart';
import '../cart/cart_screen.dart';
import '../cart/cart_state.dart';
import '../enquiry/enquiry_screen.dart';
import '../product/product_screen.dart';
import 'dashboard_cubit.dart';
import 'dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  final int initialTab;

  const DashboardScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTab != 0) {
      context.read<DashboardCubit>().setTab(widget.initialTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final currentTab = state.currentTabIndex;

        final pages = [
          const ProductScreen(),
          CartScreen(
            onBrowseProducts: () => context.read<DashboardCubit>().setTab(0),
          ),
          EnquiryScreen(
            onBrowseProducts: () => context.read<DashboardCubit>().setTab(0),
          ),
          const _ProfileTab(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: currentTab,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: NavigationBar(
              selectedIndex: currentTab,
              onDestinationSelected: (idx) {
                context.read<DashboardCubit>().setTab(idx);
              },
              backgroundColor: Colors.white,
              indicatorColor: AppColors.chipBackground,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.actionTeal),
                  label: 'Catalog',
                ),
                NavigationDestination(
                  icon: BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      if (cartState.itemCount > 0) {
                        return Badge(
                          label: Text('${cartState.itemCount}'),
                          backgroundColor: AppColors.actionTeal,
                          child: const Icon(Icons.shopping_cart_outlined),
                        );
                      }
                      return const Icon(Icons.shopping_cart_outlined);
                    },
                  ),
                  selectedIcon: BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      if (cartState.itemCount > 0) {
                        return Badge(
                          label: Text('${cartState.itemCount}'),
                          backgroundColor: AppColors.actionTeal,
                          child: const Icon(Icons.shopping_cart_rounded, color: AppColors.actionTeal),
                        );
                      }
                      return const Icon(Icons.shopping_cart_rounded, color: AppColors.actionTeal);
                    },
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.actionTeal),
                  label: 'Enquiries',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppColors.actionTeal),
                  label: 'Account',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final displayName = user?.displayName ?? 'Verified Buyer';
          final email = user?.email ?? 'buyer@vyapaarhub.com';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryNavy,
                      child: Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
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
                              'Verified GST Buyer',
                              style: TextStyle(
                                fontSize: 11,
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
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.business_center_outlined, color: AppColors.primaryNavy),
                      title: const Text('Business Details'),
                      subtitle: const Text('GSTIN, Registered Entity & Billing Address'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.credit_card_outlined, color: AppColors.primaryNavy),
                      title: const Text('Payment & Credit Terms'),
                      subtitle: const Text('Net 30, LC & Trade Credit Options'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.support_agent_rounded, color: AppColors.primaryNavy),
                      title: const Text('Trade Helpdesk'),
                      subtitle: const Text('Speak with dedicated procurement manager'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              AppButton(
                text: 'Sign Out of Account',
                icon: Icons.logout_rounded,
                type: ButtonType.destructive,
                onPressed: () async {
                  await context.read<AuthCubit>().logout();
                  if (context.mounted) {
                    context.go(AppRouter.authScreen);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
