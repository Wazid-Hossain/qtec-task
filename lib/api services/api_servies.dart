import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qtec_task/api services/model.dart';

class ApiService {
  static const _baseUrl = 'https://dummyjson.com/products';

  /// Fetch a page of `limit` items, skipping the first `skip` items.
  static Future<List<ProductModel>> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final uri = Uri.parse("$_baseUrl?limit=$limit&skip=$skip");
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load products (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>;
    return list
        .map((j) => ProductModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
