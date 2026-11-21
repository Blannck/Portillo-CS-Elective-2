import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;
  String? get userEmail => _client.auth.currentUser?.email;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign in with Email and Password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign up with Email and Password plus metadata for handle_new_user trigger
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
      },
    );
  }

  // Sign in with Google (OAuth)
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.finalexam://login-callback',
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Check if current user is admin via Database RPC
  Future<bool> checkIsAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    try {
      final res = await _client.rpc('is_admin');
      return res == true;
    } catch (_) {
      // Fallback: check profiles and roles directly
      try {
        final profile = await _client
            .from('profiles')
            .select('role_id, roles(role)')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && profile['roles'] != null) {
          final roleName = profile['roles']['role'];
          return roleName == 'admin';
        }
      } catch (_) {}
      return false;
    }
  }
}
