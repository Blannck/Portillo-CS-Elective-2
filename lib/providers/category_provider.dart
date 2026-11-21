import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'supabase_provider.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.watch(supabaseProvider));
});

class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() {
    return ref.read(categoryServiceProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(categoryServiceProvider).fetchAll(),
    );
  }

  Future<void> addCategory(String name) async {
    await ref.read(categoryServiceProvider).addCategory(name);
    state = AsyncData(await ref.read(categoryServiceProvider).fetchAll());
  }

  Future<void> updateCategory(int id, String name) async {
    await ref.read(categoryServiceProvider).updateCategory(id, name);
    state = AsyncData(await ref.read(categoryServiceProvider).fetchAll());
  }

  Future<void> deleteCategory(int id) async {
    await ref.read(categoryServiceProvider).deleteCategory(id);
    state = AsyncData(await ref.read(categoryServiceProvider).fetchAll());
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
  CategoryNotifier.new,
);
