import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  static Future<List<ProductModel>> fetchProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl?limit=$limit&skip=$skip");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = data['products'] as List;
        return products.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }
}
