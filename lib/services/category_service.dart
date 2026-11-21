import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final SupabaseClient _client;

  const CategoryService(this._client);

  Future<List<Category>> fetchAll() async {
    final data = await _client
        .from('categories')
        .select()
        .order('id', ascending: true);

    return (data as List<dynamic>)
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Category> addCategory(String name) async {
    final data = await _client
        .from('categories')
        .insert({'name': name.trim()})
        .select()
        .single();

    return Category.fromJson(data);
  }

  Future<void> updateCategory(int id, String name) async {
    final res = await _client
        .from('categories')
        .update({'name': name.trim()})
        .eq('id', id)
        .select();

    if (res.isEmpty) {
      throw Exception('Category not found or permission denied');
    }
  }

  Future<void> deleteCategory(int id) async {
    final res = await _client
        .from('categories')
        .delete()
        .eq('id', id)
        .select();

    if (res.isEmpty) {
      throw Exception('Category not found or permission denied');
    }
  }
}
