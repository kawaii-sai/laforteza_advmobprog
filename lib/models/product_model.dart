class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['title'] ?? 'Unknown Product',
      description: json['description'] ?? 'No description available.',
      imageUrl: json['thumbnail'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}