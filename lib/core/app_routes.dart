import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/product_model.dart';
import '../view/auth_screen.dart';
import '../view/dashboard_screen.dart';
import '../view/product_screen.dart';

/// Central GoRouter configuration providing declarative navigation throughout the app.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) {
          final tabIndex = (state.extra as int?) ?? 0;
          return DashboardScreen(initialTab: tabIndex);
        },
      ),
      GoRoute(
        path: '/listing',
        name: 'listing',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          final category = state.uri.queryParameters['category'];
          return ProductListingScreen(
            initialQuery: query,
            initialCategory: category,
          );
        },
      ),
      GoRoute(
        path: '/details',
        name: 'details',
        builder: (context, state) {
          final product = state.extra as Product?;
          if (product == null) {
            return const Scaffold(
              body: Center(child: Text('Product not found')),
            );
          }
          return ProductDetailScreen(product: product);
        },
      ),
    ],
  );
}
