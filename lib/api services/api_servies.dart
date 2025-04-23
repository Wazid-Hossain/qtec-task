import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qtec_task/model.dart';

class ApiService {
  static const _baseUrl = 'https://dummyjson.com/products';

  /// Fetch *all* products in one go
  static Future<List<ProductModel>> fetchAll() async {
    final uri = Uri.parse("$_baseUrl?limit=100");
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load products (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body);
    final list = (data['products'] as List);
    return list.map((j) => ProductModel.fromJson(j)).toList();
  }

  static fetchProducts() {}
}
