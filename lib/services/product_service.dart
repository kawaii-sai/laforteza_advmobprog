import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> getProducts() async {
    final productUrl = dotenv.env['PRODUCT_URL'];

    if (productUrl == null || productUrl.isEmpty) {
      throw Exception('PRODUCT_URL is not configured in env file.');
    }

    try {
      final response = await http.get(
        Uri.parse(productUrl),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load products. Status code: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      final List products = data['products'];

      return products
          .map((product) => Product.fromJson(product))
          .toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}