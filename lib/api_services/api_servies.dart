import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:qtec_task/api_services/product_hive_model.dart';
import 'model.dart'; // your existing model

class ApiService {
  static Future<List<ProductModel>> fetchProducts(int limit, int skip) async {
    final box = Hive.box<ProductHiveModel>('products');

    // Load from Hive if exists
    if (box.isNotEmpty && skip == 0) {
      return box.values
          .map(
            (hive) => ProductModel(
              id: hive.id,
              title: hive.title,
              description: hive.description,
              category: hive.category,
              price: hive.price,
              discountPercentage: hive.discountPercentage,
              rating: hive.rating,
              stock: hive.stock,
              thumbnail: hive.thumbnail,
            ),
          )
          .toList();
    }

    // Otherwise fetch from API
    final url = Uri.parse(
      'https://dummyjson.com/products?limit=$limit&skip=$skip',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['products'];
      final products = data.map((e) => ProductModel.fromJson(e)).toList();

      if (skip == 0) {
        await box.clear(); // clear cache for fresh load
        for (var product in products) {
          box.add(
            ProductHiveModel(
              id: product.id ?? 0,
              title: product.title ?? '',
              description: product.description ?? '',
              category: product.category ?? '',
              price: product.price ?? 0,
              discountPercentage: product.discountPercentage ?? 0.0,
              rating: product.rating ?? 0.0,
              stock: product.stock ?? 0,
              thumbnail: product.thumbnail ?? '',
            ),
          );
        }
      }

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }
}
