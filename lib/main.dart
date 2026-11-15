import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/routes/routes.dart';
import 'utils/app_colors.dart';
import 'utils/app_theme.dart';
import 'view/auth/auth_cubit.dart';
import 'view/cart/cart_cubit.dart';
import 'view/enquiry/enquiry_cubit.dart';
import 'view/product/product_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shallKey = GlobalKey<NavigatorState>();
late SharedPreferences sharedPreferences;

Future<void> main() async {
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
  sharedPreferences = await SharedPreferences.getInstance();

  runApp(const VyapaarHubApp());
}

/// Root widget configuring Cubit providers, Material 3 theming, and GoRouter navigation.
class VyapaarHubApp extends StatelessWidget {
  const VyapaarHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<ProductCubit>(
          create: (_) => ProductCubit(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => CartCubit(),
        ),
        BlocProvider<EnquiryCubit>(
          create: (_) => EnquiryCubit(),
        ),
      ],
      child: MaterialApp.router(
        title: 'VyapaarHub — B2B Wholesale Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
