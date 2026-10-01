import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<Cart> getCartByUserId(int userId) async {
    final response = await http.get(
      Uri.parse(Constants.cartsEndpoint),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List<dynamic> carts =
          data['carts'] ?? [];

      final cartList = carts
          .map(
            (cart) =>
                Cart.fromJson(
                  cart as Map<String, dynamic>,
                ),
          )
          .toList();

      final userCart = cartList.where(
        (cart) => cart.userId == userId,
      );

      if (userCart.isEmpty) {
        throw Exception(
          'No cart found for user ID $userId',
        );
      }

      return userCart.first;
    } else {
      throw Exception(
        'Failed to load carts: ${response.statusCode}',
      );
    }
  }

  Future<Cart> addToCartByUser({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(Constants.cartsAddEndpoint),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'userId': userId,

        'products': [
          {
            'productId': productId,
            'quantity': quantity,
          }
        ],
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final data =
          jsonDecode(response.body);

      return Cart.fromJson(data);
    } else {
      throw Exception(
        'Failed to add cart: ${response.statusCode}',
      );
    }
  }
}