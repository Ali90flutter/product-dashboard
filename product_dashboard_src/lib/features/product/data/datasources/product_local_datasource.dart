import 'dart:convert';
import 'package:flutter/services.dart';
import '../dto/product_dto.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductDto>> loadSeedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  @override
  Future<List<ProductDto>> loadSeedProducts() async {
    final raw = await rootBundle.loadString('assets/products_seed.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['products'] as List).cast<Map<String, dynamic>>();
    return list.map(ProductDto.fromJson).toList();
  }
}
