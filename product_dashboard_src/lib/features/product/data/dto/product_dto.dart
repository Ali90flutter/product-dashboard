import '../../domain/entities/product.dart';

class ProductDto {
  final int id;
  final String title;
  final String category;
  final num price;
  final int stock;

  ProductDto({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      price: (json['price'] ?? 0) as num,
      stock: (json['stock'] ?? 0) as int,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: title,
      category: category,
      price: price.toDouble(),
      stockStatus: stock > 0 ? StockStatus.inStock : StockStatus.outOfStock,
    );
  }
}
