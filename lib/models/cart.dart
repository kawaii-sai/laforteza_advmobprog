class Cart {
  final int id;
  final List<CartProduct> products;
  final int totalProducts;
  final int totalQuantity;
  final int userId;
  final double discountedTotal;
  final double total;

  Cart({
    required this.id,
    required this.products,
    required this.totalProducts,
    required this.totalQuantity,
    required this.userId,
    required this.discountedTotal,
    required this.total,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final List<dynamic> productsJson = json['products'] ?? [];

    return Cart(
      id: (json['id'] as num?)?.toInt() ?? 0,
      products: productsJson
          .map(
            (product) =>
                CartProduct.fromJson(product as Map<String, dynamic>),
          )
          .toList(),
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      discountedTotal:
          (json['discountedTotal'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CartProduct {
  final int id;
  final String title;
  final double price;
  int quantity;
  final double discountPercentage;
  final double discountAmount;
  double total;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.discountPercentage,
    required this.discountAmount,
    required this.total,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Unknown Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount:
          (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  CartProduct copyWith({
    int? quantity,
    double? total,
  }) {
    return CartProduct(
      id: id,
      title: title,
      price: price,
      quantity: quantity ?? this.quantity,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      total: total ?? this.total,
      thumbnail: thumbnail,
    );
  }
}