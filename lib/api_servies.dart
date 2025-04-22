// api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}
