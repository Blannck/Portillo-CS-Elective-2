import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _client;

  ProfileService(this._client);

  Future<UserProfile?> fetchCurrentProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('profiles')
        .select('*, roles(role)')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
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
