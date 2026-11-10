import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductDialogs {
  static Future<void> showAddProductDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '10');
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_shopping_cart, size: 22),
            SizedBox(width: 8),
            Text('Add New Product'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'e.g. Leather Oxford Shoes',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (₱)',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final numVal = double.tryParse(val.trim());
                    if (numVal == null || numVal < 0) {
                      return 'Enter a valid positive price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter stock';
                    }
                    final intVal = int.tryParse(val.trim());
                    if (intVal == null || intVal < 0) {
                      return 'Enter a valid stock number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Add Product'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final nav = Navigator.of(ctx);
                final scaffold = ScaffoldMessenger.of(context);
                final productProvider = context.read<ProductProvider>();
                final errorColor = Theme.of(context).colorScheme.error;
                final success = await productProvider.addProduct(
                  name: nameController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  stock: int.parse(stockController.text.trim()),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                nav.pop();
                if (success) {
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully!'),
                    ),
                  );
                } else {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        productProvider.errorMessage ?? 'Failed to add product.',
                      ),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<void> showEditProductDialog(
    BuildContext context,
    Product product,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toStringAsFixed(2),
    );
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );
    final descController = TextEditingController(
      text: product.description ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, size: 22),
            const SizedBox(width: 8),
            Text('Edit ${product.name}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (₱)',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final numVal = double.tryParse(val.trim());
                    if (numVal == null || numVal < 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter stock';
                    }
                    final intVal = int.tryParse(val.trim());
                    if (intVal == null || intVal < 0) {
                      return 'Enter a valid stock';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Changes'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final nav = Navigator.of(ctx);
                final scaffold = ScaffoldMessenger.of(context);
                final productProvider = context.read<ProductProvider>();
                final errorColor = Theme.of(context).colorScheme.error;
                final success = await productProvider.updateProduct(
                  id: product.id,
                  name: nameController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  stock: int.parse(stockController.text.trim()),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
                nav.pop();
                if (success) {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Updated "${product.name}" successfully!'),
                    ),
                  );
                } else {
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        productProvider.errorMessage ??
                            'Failed to update product.',
                      ),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  static Future<void> showDeleteConfirmDialog(
    BuildContext context,
    Product product,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text('Delete Product?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${product.name}" (ID: ${product.id})? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final scaffold = ScaffoldMessenger.of(context);
              final productProvider = context.read<ProductProvider>();
              final errorColor = Theme.of(context).colorScheme.error;
              final success = await productProvider.deleteProduct(product.id);
              nav.pop();
              if (success) {
                scaffold.showSnackBar(
                  SnackBar(content: Text('Deleted "${product.name}"')),
                );
              } else {
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text(
                      productProvider.errorMessage ??
                          'Failed to delete product.',
                    ),
                    backgroundColor: errorColor,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static void showSupabaseSetupDialog(BuildContext context) {
    const sqlScript = '''CREATE TABLE IF NOT EXISTS public.products (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  category_id INT DEFAULT 1,
  stock INT DEFAULT 10,
  image_url TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access" 
ON public.products FOR SELECT USING (true);

-- Allow public insert, update, delete
CREATE POLICY "Allow public insert" 
ON public.products FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update" 
ON public.products FOR UPDATE USING (true);

CREATE POLICY "Allow public delete" 
ON public.products FOR DELETE USING (true);''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: Colors.teal),
            SizedBox(width: 8),
            Text('Supabase Table Setup'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'If the "products" table has not been created yet in your Supabase dashboard, run this SQL in your Supabase SQL Editor:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SelectableText(
                    sqlScript,
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy SQL'),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: sqlScript));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SQL copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
