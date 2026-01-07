import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;

  /// Session persistence
  final List<Product> _cache = [];

  ProductRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<List<Product>> getProducts() async {
    if (_cache.isNotEmpty) return List.unmodifiable(_cache);

    try {
      final dtos = await remote.fetchProducts();
      _cache
        ..clear()
        ..addAll(dtos.map((e) => e.toEntity()));
      return List.unmodifiable(_cache);
    } catch (_) {
      // Fallback to local seed data if network fails
      final dtos = await local.loadSeedProducts();
      _cache
        ..clear()
        ..addAll(dtos.map((e) => e.toEntity()));
      return List.unmodifiable(_cache);
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    _cache.insert(0, product);
    return product;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final idx = _cache.indexWhere((p) => p.id == product.id);
    if (idx == -1) return product;
    _cache[idx] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(int id) async {
    _cache.removeWhere((p) => p.id == id);
  }
}
