import 'package:dio/dio.dart';
import '../dto/product_dto.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductDto>> fetchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;
  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductDto>> fetchProducts() async {
    final res = await dio.get('https://dummyjson.com/products?limit=100');
    final data = res.data as Map<String, dynamic>;
    final list = (data['products'] as List).cast<Map<String, dynamic>>();
    return list.map(ProductDto.fromJson).toList();
  }
}
