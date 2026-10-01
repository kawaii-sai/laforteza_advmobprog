import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartProduct> _items = [];

  List<CartProduct> get items => List.unmodifiable(_items);

  int get totalItems {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  double get subtotal {
    return _items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  bool get isEmpty => _items.isEmpty;

  // Add a product with the selected quantity.
  void addProduct(
    Product product, {
    int quantity = 1,
  }) {
    final existingIndex =
        _items.indexWhere((item) => item.id == product.id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;

      _items[existingIndex].total =
          _items[existingIndex].price *
              _items[existingIndex].quantity;
    } else {
      _items.add(
        CartProduct(
          id: product.id,
          title: product.name,
          price: product.price,
          quantity: quantity,
          discountPercentage: 0,
          discountAmount: 0,
          total: product.price * quantity,
          thumbnail: product.imageUrl,
        ),
      );
    }

    notifyListeners();
  }

  void increaseQuantity(int productId) {
    final index =
        _items.indexWhere((item) => item.id == productId);

    if (index != -1) {
      _items[index].quantity++;

      _items[index].total =
          _items[index].price *
              _items[index].quantity;

      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    final index =
        _items.indexWhere((item) => item.id == productId);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;

      _items[index].total =
          _items[index].price *
              _items[index].quantity;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere(
      (item) => item.id == productId,
    );

    notifyListeners();
  }

  void clearCart() {
    _items.clear();

    notifyListeners();
  }

  void confirmOrder() {
    clearCart();
  }
}