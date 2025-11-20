import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl = "https://dummyjson.com";

  // Fetch products
  static Future<List<ProductModel>> fetchProducts() async {
    final url = Uri.parse("$baseUrl/products?limit=100");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> products = data['products'];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  // Fetch categories
  static Future<List<CategoryModel>> fetchCategories() async {
    final url = Uri.parse("$baseUrl/products/categories");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> categories = jsonDecode(response.body);
      return categories.map((e) => CategoryModel.fromJson(e)).toList();
    }
    return [];
  }
}
