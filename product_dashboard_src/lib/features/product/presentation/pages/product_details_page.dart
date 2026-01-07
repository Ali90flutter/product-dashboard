import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../blocs/product_cubit.dart';
import '../widgets/product_form_dialog.dart';

class ProductDetailsPage extends StatelessWidget {
  final int? productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final id = productId;
    if (id == null) {
      return const Center(child: Text('Invalid product ID'));
    }

    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final p = context.read<ProductCubit>().byId(id);
        if (p == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Product not found'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/products'),
                  child: const Text('Back to Products'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    onPressed: () async {
                      final updated = await showProductFormDialog(
                        context: context,
                        mode: ProductFormMode.edit,
                        initial: p,
                      );
                      if (updated != null && context.mounted) {
                        await context.read<ProductCubit>().update(updated);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Row(label: 'Product ID', value: p.id.toString()),
              _Row(label: 'Category', value: p.category),
              _Row(label: 'Price', value: '\$ ${p.price.toStringAsFixed(2)}'),
              _Row(
                label: 'Stock',
                value: p.stockStatus == StockStatus.inStock
                    ? 'In stock'
                    : 'Out of stock',
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/products'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Products'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
