import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  int? _categoryId;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  // Curated sample pickleball images for convenience
  final List<Map<String, String>> _imagePresets = [
    {
      'label': 'Carbon Paddle',
      'url':
          'https://images.unsplash.com/photo-1617083934555-563d404092b3?w=600&auto=format&fit=crop&q=80',
    },
    {
      'label': 'Court Shoes',
      'url':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
    },
    {
      'label': 'Pickleballs',
      'url':
          'https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?w=600&auto=format&fit=crop&q=80',
    },
    {
      'label': 'Tour Backpack',
      'url':
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameController.text = p.name;
      _descController.text = p.description ?? '';
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();
      _imageUrlController.text = p.imageUrl ?? '';
      _categoryId = p.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final imageUrl = _imageUrlController.text.trim();

      if (_isEditing) {
        await ref.read(productProvider.notifier).updateProduct(
              widget.product!.copyWith(
                name: name,
                description: desc.isNotEmpty ? desc : null,
                price: price,
                stock: stock,
                categoryId: _categoryId,
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              ),
            );
      } else {
        await ref.read(productProvider.notifier).addProduct(
              Product(
                id: 0,
                name: name,
                description: desc.isNotEmpty ? desc : null,
                price: price,
                stock: stock,
                categoryId: _categoryId,
                imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
              ),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Product updated successfully' : 'Product created successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g. Selkirk Vanguard Control Paddle',
                  prefixIcon: Icon(Icons.sports_tennis),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'A product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              categoriesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Text(
                  'Could not load categories: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
                data: (categories) => DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                  ],
                  onChanged: (val) => setState(() => _categoryId = val),
                  validator: (val) =>
                      val == null ? 'Please select a category' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Price & Stock in Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price (\$) *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Price required';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Must be >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Stock required';
                        }
                        final parsed = int.tryParse(v.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Whole number >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Technical specifications, weight, grip size...',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://images.unsplash.com/...',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 10),

              // Preset Image Quick Buttons
              const Text(
                'Or choose a preset pickleball image:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final preset in _imagePresets)
                    ActionChip(
                      avatar: const Icon(Icons.photo_outlined, size: 16),
                      label: Text(preset['label']!),
                      onPressed: () {
                        setState(() {
                          _imageUrlController.text = preset['url']!;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Image Preview
              if (_imageUrlController.text.trim().isNotEmpty) ...[
                const Text(
                  'Image Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    _imageUrlController.text.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Text(
                        'Unable to load image from URL',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),
              // Save Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saving ? null : _saveProduct,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _saving
                      ? 'Saving Product...'
                      : (_isEditing ? 'Update Product' : 'Add Product to Catalog'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
