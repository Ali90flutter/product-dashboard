import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> all; // raw list cached in-memory
  final String searchQuery;
  final String? categoryFilter;
  final StockStatus? stockFilter;

  final int? sortColumnIndex;
  final bool sortAscending;

  final String? error;

  const ProductState({
    required this.status,
    required this.all,
    required this.searchQuery,
    required this.categoryFilter,
    required this.stockFilter,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.error,
  });

  factory ProductState.initial() => const ProductState(
        status: ProductStatus.initial,
        all: [],
        searchQuery: '',
        categoryFilter: null,
        stockFilter: null,
        sortColumnIndex: null,
        sortAscending: true,
        error: null,
      );

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? all,
    String? searchQuery,
    String? categoryFilter,
    StockStatus? stockFilter,
    int? sortColumnIndex,
    bool? sortAscending,
    String? error,
  }) {
    return ProductState(
      status: status ?? this.status,
      all: all ?? this.all,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      stockFilter: stockFilter ?? this.stockFilter,
      sortColumnIndex: sortColumnIndex ?? this.sortColumnIndex,
      sortAscending: sortAscending ?? this.sortAscending,
      error: error,
    );
  }

  List<Product> get filtered {
    Iterable<Product> items = all;

    if (categoryFilter != null && categoryFilter!.isNotEmpty) {
      items = items.where((p) => p.category == categoryFilter);
    }
    if (stockFilter != null) {
      items = items.where((p) => p.stockStatus == stockFilter);
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.id.toString().contains(q));
    }

    final list = items.toList();

    if (sortColumnIndex != null) {
      final c = sortColumnIndex!;
      list.sort((a, b) {
        int cmp;
        switch (c) {
          case 0:
            cmp = a.id.compareTo(b.id);
            break;
          case 1:
            cmp = a.name.compareTo(b.name);
            break;
          case 2:
            cmp = a.category.compareTo(b.category);
            break;
          case 3:
            cmp = a.price.compareTo(b.price);
            break;
          case 4:
            cmp = a.stockStatus.index.compareTo(b.stockStatus.index);
            break;
          default:
            cmp = 0;
        }
        return sortAscending ? cmp : -cmp;
      });
    }

    return list;
  }

  List<String> get categories =>
      all.map((e) => e.category).toSet().toList()..sort();

  @override
  List<Object?> get props => [
        status,
        all,
        searchQuery,
        categoryFilter,
        stockFilter,
        sortColumnIndex,
        sortAscending,
        error,
      ];
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repo;

  ProductCubit(this.repo) : super(ProductState.initial());

  Future<void> load() async {
    emit(state.copyWith(status: ProductStatus.loading, error: null));
    try {
      final products = await repo.getProducts();
      emit(state.copyWith(status: ProductStatus.success, all: products));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, error: e.toString()));
    }
  }

  void setSearch(String v) => emit(state.copyWith(searchQuery: v));
  void setCategory(String? v) => emit(state.copyWith(categoryFilter: v));
  void setStock(StockStatus? v) => emit(state.copyWith(stockFilter: v));

  void setSort(int columnIndex, bool ascending) {
    emit(state.copyWith(sortColumnIndex: columnIndex, sortAscending: ascending));
  }

  Future<void> add(Product p) async {
    await repo.addProduct(p);
    final updated = await repo.getProducts();
    emit(state.copyWith(all: updated));
  }

  Future<void> update(Product p) async {
    await repo.updateProduct(p);
    final updated = await repo.getProducts();
    emit(state.copyWith(all: updated));
  }

  Future<void> remove(int id) async {
    await repo.deleteProduct(id);
    final updated = await repo.getProducts();
    emit(state.copyWith(all: updated));
  }

  Product? byId(int id) {
    try {
      return state.all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
