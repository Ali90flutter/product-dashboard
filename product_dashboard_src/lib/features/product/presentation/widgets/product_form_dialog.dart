import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

enum ProductFormMode { create, edit }

Future<Product?> showProductFormDialog({
  required BuildContext context,
  required ProductFormMode mode,
  Product? initial,
}) {
  return showDialog<Product>(
    context: context,
    builder: (_) => _ProductFormDialog(mode: mode, initial: initial),
  );
}

class _ProductFormDialog extends StatefulWidget {
  final ProductFormMode mode;
  final Product? initial;

  const _ProductFormDialog({required this.mode, required this.initial});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController idCtrl;
  late final TextEditingController nameCtrl;
  late final TextEditingController categoryCtrl;
  late final TextEditingController priceCtrl;

  StockStatus stock = StockStatus.inStock;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    idCtrl = TextEditingController(text: p?.id.toString() ?? '');
    nameCtrl = TextEditingController(text: p?.name ?? '');
    categoryCtrl = TextEditingController(text: p?.category ?? '');
    priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    stock = p?.stockStatus ?? StockStatus.inStock;
  }

  @override
  void dispose() {
    idCtrl.dispose();
    nameCtrl.dispose();
    categoryCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == ProductFormMode.edit;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'Add Product'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: idCtrl,
                  readOnly: isEdit,
                  decoration: InputDecoration(
                    labelText: 'Product ID',
                    border: const OutlineInputBorder(),
                    helperText: isEdit ? 'ID cannot be changed' : null,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'ID is required';
                    final id = int.tryParse(v.trim());
                    if (id == null || id <= 0) {
                      return 'Enter a valid positive integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Category is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Price is required';
                    final price = double.tryParse(v.trim());
                    if (price == null || price < 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<StockStatus>(
                  value: stock,
                  decoration: const InputDecoration(
                    labelText: 'Stock status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: StockStatus.inStock,
                      child: Text('In stock'),
                    ),
                    DropdownMenuItem(
                      value: StockStatus.outOfStock,
                      child: Text('Out of stock'),
                    ),
                  ],
                  onChanged: (v) => setState(() => stock = v ?? StockStatus.inStock),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            final p = Product(
              id: int.parse(idCtrl.text.trim()),
              name: nameCtrl.text.trim(),
              category: categoryCtrl.text.trim(),
              price: double.parse(priceCtrl.text.trim()),
              stockStatus: stock,
            );

            Navigator.pop(context, p);
          },
          child: Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
