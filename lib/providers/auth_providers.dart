import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'cart_provider.dart';
import 'supabase_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseProvider));
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(supabaseProvider));
});

/// Listens to Supabase auth changes (signed in / signed out / token refresh).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current authenticated user
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authServiceProvider).currentUser;
});

/// Current user's email
final userEmailProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(authServiceProvider).userEmail;
});

/// Checks if current user has the admin role via RPC or profiles table
final isAdminProvider = FutureProvider<bool>((ref) async {
  ref.watch(authStateProvider);
  return await ref.watch(authServiceProvider).checkIsAdmin();
});

/// Current user's profile
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(authStateProvider);
  return await ref.watch(profileServiceProvider).fetchCurrentProfile();
});

/// Handles sign in / sign up / sign out / google sign in actions.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthService get _service => ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _service.signInWithEmailPassword(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _service.signUpWithEmailPassword(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await _service.signInWithGoogle();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signInWithGoogleDemo() async {
    state = const AsyncLoading();
    try {
      await _service.signInWithGoogleDemo();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    // Empty the cart on logout as required
    ref.read(cartProvider.notifier).clearCart();
    state = await AsyncValue.guard(() => _service.signOut());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);
