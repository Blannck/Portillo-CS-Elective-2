import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';

class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  Future<void> _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final textController = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            hintText: 'e.g. Overgrips',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && textController.text.trim().isNotEmpty) {
      final name = textController.text.trim();
      try {
        if (isEditing) {
          await ref
              .read(categoriesProvider.notifier)
              .updateCategory(category.id, name);
        } else {
          await ref.read(categoriesProvider.notifier).addCategory(name);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Category updated to "$name"'
                    : 'Category "$name" created',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\nProducts in this category will become uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await ref
            .read(categoriesProvider.notifier)
            .deleteCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${category.name}"'),
              backgroundColor: AppColors.courtNavy,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories found. Tap + to add one.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return Card(
                elevation: 1,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightBg,
                    child: Icon(Icons.category, color: AppColors.primary),
                  ),
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: 'Edit',
                        onPressed: () => _showAddEditDialog(
                          context,
                          ref,
                          category: cat,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(context, ref, cat),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
