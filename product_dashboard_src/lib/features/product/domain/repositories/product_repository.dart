import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}
