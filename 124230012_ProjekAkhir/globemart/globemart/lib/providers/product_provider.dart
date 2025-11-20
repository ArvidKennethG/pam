import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  List<CategoryModel> categories = [];

  bool isLoading = false;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      await fetchProducts();
      await fetchCategories();
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    const url = 'https://dummyjson.com/products?limit=50';
    final res = await http.get(Uri.parse(url));

    final data = jsonDecode(res.body);
    final List list = data['products'];

    products = list.map((e) => ProductModel.fromJson(e)).toList();
    filteredProducts = List.from(products);
  }

  Future<void> fetchCategories() async {
    const url = 'https://dummyjson.com/products/categories';
    final res = await http.get(Uri.parse(url));

    final data = jsonDecode(res.body);
    final List list = data;

    categories = list.map((e) => CategoryModel.fromJson(e)).toList();
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products
          .where((p) => p.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void resetFilter() {
    filteredProducts = List.from(products);
    notifyListeners();
  }

  void filterByCategory(String categoryName) {
    filteredProducts =
        products.where((p) => p.category.toLowerCase() == categoryName.toLowerCase()).toList();
    notifyListeners();
  }
}
