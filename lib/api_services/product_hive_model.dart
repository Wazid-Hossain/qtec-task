import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final double discountPercentage;

  @HiveField(6)
  final double rating;

  @HiveField(7)
  final int stock;

  @HiveField(8)
  final String thumbnail;

  ProductHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
  });
}
