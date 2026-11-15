import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../main.dart';
import '../../../view/auth/auth_cubit.dart';
import '../../../view/auth/auth_screen.dart';
import '../../../view/cart/cart_cubit.dart';
import '../../../view/cart/cart_screen.dart';
import '../../../view/dashboard/dashboard_cubit.dart';
import '../../../view/dashboard/dashboard_screen.dart';
import '../../../view/enquiry/enquiry_cubit.dart';
import '../../../view/enquiry/enquiry_screen.dart';
import '../../../view/product/product_cubit.dart';
import '../../../view/product/product_screen.dart';
import '../../../view/product_detail/product_detail_cubit.dart';
import '../../../view/product_detail/product_detail_screen.dart';
import '../../../view/splash/splash_cubit.dart';
import '../../../view/splash/splash_screen.dart';
import '../models/product_model.dart';

class AppRouter {
  static const String splashScreen = "/";
  static const String authScreen = "/auth";
  static const String dashboardScreen = "/dashboard";
  static const String productListingScreen = "/listing";
  static const String productDetailScreen = "/details";
  static const String cartScreen = "/cart";
  static const String enquiryScreen = "/enquiry";
}

final GoRouter router = GoRouter(
  initialLocation: AppRouter.splashScreen,
  navigatorKey: navigatorKey,
  routes: <RouteBase>[
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.splashScreen,
      name: AppRouter.splashScreen,
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => SplashCubit(),
            child: const SplashScreen(),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.authScreen,
      name: AppRouter.authScreen,
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => AuthCubit(),
            child: const AuthScreen(),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.dashboardScreen,
      name: AppRouter.dashboardScreen,
      pageBuilder: (context, state) {
        final tabIndex = (state.extra as int?) ?? 0;
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => DashboardCubit(initialTab: tabIndex),
            child: DashboardScreen(initialTab: tabIndex),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.productListingScreen,
      name: AppRouter.productListingScreen,
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => ProductCubit(),
            child: ProductScreen(
              initialQuery: state.uri.queryParameters['q'],
              initialCategory: state.uri.queryParameters['category'],
            ),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.productDetailScreen,
      name: AppRouter.productDetailScreen,
      pageBuilder: (context, state) {
        final product = state.extra as Product?;
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => ProductDetailCubit(product: product),
            child: ProductDetailScreen(product: product),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.cartScreen,
      name: AppRouter.cartScreen,
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => CartCubit(),
            child: const CartScreen(),
          ),
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: navigatorKey,
      path: AppRouter.enquiryScreen,
      name: AppRouter.enquiryScreen,
      pageBuilder: (context, state) {
        return CupertinoPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => EnquiryCubit(),
            child: const EnquiryScreen(),
          ),
        );
      },
    ),
  ],
);
