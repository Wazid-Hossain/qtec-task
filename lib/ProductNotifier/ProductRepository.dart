// lib/repository/product_repository.dart
import 'package:qtec_task/api_services/api_servies.dart';

import 'package:qtec_task/api_services/model.dart';

class ProductRepository {
  Future<List<ProductModel>> fetchProducts() async {
    return await ApiService.fetchProducts();
  }
}
