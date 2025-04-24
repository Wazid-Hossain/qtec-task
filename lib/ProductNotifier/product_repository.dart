import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:qtec_task/api_services/model.dart';
import 'package:qtec_task/api_services/product_hive_model.dart';

class ProductRepository {
  final String _baseUrl = 'https://dummyjson.com/products';

  /// Fetch paginated products (with Hive caching on first page)
  Future<List<ProductModel>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    final box = Hive.box<ProductHiveModel>('products');

    // ✅ Use cache if available and requesting first page
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

    final response = await http.get(
      Uri.parse('$_baseUrl?limit=$limit&skip=$skip'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['products'];
      final products = data.map((e) => ProductModel.fromJson(e)).toList();

      // ✅ Save to cache if first page
      if (skip == 0) {
        await box.clear();
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

      return products.cast<ProductModel>();
    } else {
      throw Exception('Failed to load products');
    }
  }

  /// Fetch all products (bypasses Hive cache, for full list use case)
  Future<List<ProductModel>> fetchAllProducts() async {
    List<ProductModel> allProducts = [];
    int skip = 0;
    const int limit = 100;
    bool hasMore = true;

    while (hasMore) {
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'] ?? [];

        final parsed = products.map((e) => ProductModel.fromJson(e)).toList();
        allProducts.addAll(parsed.cast<ProductModel>());

        skip += limit;
        hasMore = allProducts.length < (data['total'] ?? 0);
      } else {
        throw Exception('Failed to load all products');
      }
    }

    return allProducts;
  }
}
