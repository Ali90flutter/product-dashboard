import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../blocs/product_cubit.dart';
import '../widgets/product_form_dialog.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state.status == ProductStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductStatus.failure) {
          return Center(child: Text(state.error ?? 'Something went wrong'));
        }

        final products = state.filtered;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _CategoryFilter(
                    value: state.categoryFilter,
                    options: state.categories,
                    onChanged: (v) =>
                        context.read<ProductCubit>().setCategory(v),
                  ),
                  _StockFilter(
                    value: state.stockFilter,
                    onChanged: (v) => context.read<ProductCubit>().setStock(v),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final created = await showProductFormDialog(
                        context: context,
                        mode: ProductFormMode.create,
                      );
                      if (created != null && context.mounted) {
                        await context.read<ProductCubit>().add(created);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortAscending: state.sortAscending,
                      sortColumnIndex: state.sortColumnIndex,
                      columns: [
                        DataColumn(
                          label: const Text('ID'),
                          onSort: (i, asc) =>
                              context.read<ProductCubit>().setSort(i, asc),
                        ),
                        DataColumn(
                          label: const Text('Name'),
                          onSort: (i, asc) =>
                              context.read<ProductCubit>().setSort(i, asc),
                        ),
                        DataColumn(
                          label: const Text('Category'),
                          onSort: (i, asc) =>
                              context.read<ProductCubit>().setSort(i, asc),
                        ),
                        DataColumn(
                          numeric: true,
                          label: const Text('Price'),
                          onSort: (i, asc) =>
                              context.read<ProductCubit>().setSort(i, asc),
                        ),
                        DataColumn(
                          label: const Text('Stock'),
                          onSort: (i, asc) =>
                              context.read<ProductCubit>().setSort(i, asc),
                        ),
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: products.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(p.id.toString()),
                              onTap: () => context.go('/products/${p.id}'),
                            ),
                            DataCell(
                              Text(p.name),
                              onTap: () => context.go('/products/${p.id}'),
                            ),
                            DataCell(
                              Text(p.category),
                              onTap: () => context.go('/products/${p.id}'),
                            ),
                            DataCell(
                              Text(p.price.toStringAsFixed(2)),
                              onTap: () => context.go('/products/${p.id}'),
                            ),
                            DataCell(
                              _StockChip(p.stockStatus),
                              onTap: () => context.go('/products/${p.id}'),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () async {
                                      final updated = await showProductFormDialog(
                                        context: context,
                                        mode: ProductFormMode.edit,
                                        initial: p,
                                      );
                                      if (updated != null && context.mounted) {
                                        await context
                                            .read<ProductCubit>()
                                            .update(updated);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete product?'),
                                          content:
                                              Text('This will remove “${p.name}”.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true && context.mounted) {
                                        await context.read<ProductCubit>().remove(p.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StockChip extends StatelessWidget {
  final StockStatus status;
  const _StockChip(this.status);

  @override
  Widget build(BuildContext context) {
    final label = status == StockStatus.inStock ? 'In stock' : 'Out of stock';
    final icon = status == StockStatus.inStock
        ? Icons.check_circle_outline
        : Icons.remove_circle_outline;

    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _CategoryFilter({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('All')),
          ...options.map((c) => DropdownMenuItem(value: c, child: Text(c))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _StockFilter extends StatelessWidget {
  final StockStatus? value;
  final ValueChanged<StockStatus?> onChanged;

  const _StockFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<StockStatus>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Availability',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: null, child: Text('All')),
          DropdownMenuItem(value: StockStatus.inStock, child: Text('In stock')),
          DropdownMenuItem(
              value: StockStatus.outOfStock, child: Text('Out of stock')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
