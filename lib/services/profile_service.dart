import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  Future<UserProfile?> fetchCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select('*, roles(role)')
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      return UserProfile.fromJson(data);
    }

    // Auto-heal: In case profile was not inserted by trigger, create it now
    try {
      final roleData = await _client
          .from('roles')
          .select('id')
          .eq('role', 'customer')
          .maybeSingle();

      final roleId = roleData?['id'] ?? 1;

      final inserted = await _client
          .from('profiles')
          .insert({
            'id': user.id,
            'email': user.email,
            'firstname': user.userMetadata?['firstname'] ?? 'Player',
            'lastname': user.userMetadata?['lastname'] ?? '',
            'role_id': roleId,
          })
          .select('*, roles(role)')
          .single();

      return UserProfile.fromJson(inserted);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String firstname,
    required String lastname,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('profiles').update({
      'firstname': firstname.trim(),
      'lastname': lastname.trim(),
    }).eq('id', userId);
  }

  // Admin function: fetch all profiles
  Future<List<UserProfile>> fetchAllProfiles() async {
    final data = await _client
        .from('profiles')
        .select('*, roles(role)')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
