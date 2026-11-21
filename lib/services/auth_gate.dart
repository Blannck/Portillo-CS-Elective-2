import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../pages/auth/login_page.dart';
import '../pages/products_page.dart';
import '../providers/auth_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Loading PicklePro Shop...',
                style: TextStyle(color: AppColors.slateMuted),
              ),
            ],
          ),
        ),
      ),
      error: (_, _) => const LoginPage(),
      data: (state) {
        final session = state.session;
        return session == null ? const LoginPage() : const ProductsPage();
      },
    );
  }
}
