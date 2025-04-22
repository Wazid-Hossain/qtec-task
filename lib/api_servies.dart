import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qtec_task/model.dart';

class ApiService {
  static const String _baseUrl =
      'https://fakestoreapi.com/products'; // Replace with your API URL

  /// Fetch all products from the API
  static Future<List<product_model>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => product_model.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}
