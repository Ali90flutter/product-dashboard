import 'package:equatable/equatable.dart';

enum StockStatus { inStock, outOfStock }

class Product extends Equatable {
  final int id;
  final String name;
  final String category;
  final double price;
  final StockStatus stockStatus;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockStatus,
  });

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    StockStatus? stockStatus,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }

  @override
  List<Object?> get props => [id, name, category, price, stockStatus];
}
