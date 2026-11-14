import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_colors.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/enquiry_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/cart/cart_cubit.dart';
import 'logic/enquiry/enquiry_cubit.dart';
import 'logic/product/product_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize persistent storage
  final sharedPreferences = await SharedPreferences.getInstance();
  final storageService = StorageService(sharedPreferences);

  // Initialize network & repositories
  final apiService = ApiService();
  final productRepository = ProductRepository(apiService: apiService);
  final cartRepository = CartRepository(storageService);
  final enquiryRepository = EnquiryRepository(storageService);
  final authRepository = AuthRepository(storageService);

  runApp(
    VyapaarHubApp(
      productRepository: productRepository,
      cartRepository: cartRepository,
      enquiryRepository: enquiryRepository,
      authRepository: authRepository,
    ),
  );
}

/// Root widget configuring Cubit providers, Material 3 theming, and GoRouter navigation.
class VyapaarHubApp extends StatelessWidget {
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final EnquiryRepository enquiryRepository;
  final AuthRepository authRepository;

  const VyapaarHubApp({
    super.key,
    required this.productRepository,
    required this.cartRepository,
    required this.enquiryRepository,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authRepository),
        ),
        BlocProvider<ProductCubit>(
          create: (_) => ProductCubit(productRepository),
        ),
        BlocProvider<CartCubit>(
          create: (_) => CartCubit(cartRepository),
        ),
        BlocProvider<EnquiryCubit>(
          create: (_) => EnquiryCubit(enquiryRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'VyapaarHub — B2B Wholesale Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
