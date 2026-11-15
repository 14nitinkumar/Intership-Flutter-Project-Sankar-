import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../utils/common_widgets/app_button.dart';
import '../../utils/common_widgets/app_text_field.dart';
import '../../utils/routes/routes.dart';
import '../../utils/app_colors.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.isLoggedIn) {
          context.go(AppRouter.dashboardScreen);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.actionTeal,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VyapaarHub B2B',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'India\'s Verified Wholesale Marketplace',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primaryNavy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Sign In'),
                        Tab(text: 'Register Business'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _LoginForm(isLoading: state.isLoading),
                        _SignUpForm(isLoading: state.isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginForm extends StatefulWidget {
  final bool isLoading;
  const _LoginForm({required this.isLoading});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController(text: 'buyer@vyapaarhub.com');
  final _passCtrl = TextEditingController(text: 'secret123');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _emailCtrl,
          labelText: 'Business Email',
          hintText: 'e.g. buyer@store.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _passCtrl,
          labelText: 'Password',
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Sign In to Portal',
          icon: Icons.login_rounded,
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              _emailCtrl.text = 'buyer@vyapaarhub.com';
              _passCtrl.text = 'secret123';
              _submit();
            },
            child: const Text(
              'Use Quick Demo Credentials',
              style: TextStyle(
                color: AppColors.actionTeal,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatefulWidget {
  final bool isLoading;
  const _SignUpForm({required this.isLoading});

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().signup(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _nameCtrl,
          labelText: 'Contact Person / Business Name',
          hintText: 'e.g. Rahul Sharma Retailers',
          prefixIcon: Icons.business_rounded,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _emailCtrl,
          labelText: 'Email Address',
          hintText: 'e.g. rahul@business.in',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _passCtrl,
          labelText: 'Password',
          hintText: 'At least 6 characters',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Create Business Account',
          icon: Icons.app_registration_rounded,
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
