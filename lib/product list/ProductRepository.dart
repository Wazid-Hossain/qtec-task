// lib/repository/product_repository.dart
import 'package:qtec_task/api_servies.dart';
import 'package:qtec_task/model.dart';

class ProductRepository {
  Future<List<ProductModel>> fetchProducts() async {
    return await ApiService.fetchProducts();
  }
}
