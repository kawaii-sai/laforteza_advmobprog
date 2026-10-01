import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';

class DetailScreen extends StatefulWidget {
  final Product? product;
  final CartProduct? cartProduct;

  const DetailScreen({
    super.key,
    this.product,
    this.cartProduct,
  }) : assert(
          product != null || cartProduct != null,
          'Either product or cartProduct must be provided.',
        );

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int quantity = 1;
  bool isAddingToCart = false;

  void addToCart() {
    if (widget.product == null) return;

    setState(() {
      isAddingToCart = true;
    });

    final cartProvider = context.read<CartProvider>();

    cartProvider.addProduct(
      widget.product!,
      quantity: quantity,
    );

    setState(() {
      isAddingToCart = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product!.name} x$quantity added to cart!',
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/cart',
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.product?.name ??
        widget.cartProduct?.title ??
        'Product';

    final String description =
        widget.product?.description ??
        'Product from your shopping cart.';

    final String imageUrl =
        widget.product?.imageUrl ??
        widget.cartProduct?.thumbnail ??
        '';

    final double price =
        widget.product?.price ??
        widget.cartProduct?.price ??
        0.0;

    final bool isFromCart =
        widget.cartProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Center(
              child: SizedBox(
                height: 250,
                width: double.infinity,

                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                      ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,

              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '\$${price.toStringAsFixed(2)}',

              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            if (isFromCart)
              Text(
                'Quantity in Cart: ${widget.cartProduct!.quantity}',

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Row(
                children: [
                  const Text(
                    'Quantity:',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              quantity--;
                            });
                          }
                        : null,

                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),

                  Text(
                    quantity.toString(),

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },

                    icon: const Icon(
                      Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            if (!isFromCart)
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed:
                      isAddingToCart
                          ? null
                          : addToCart,

                  icon: isAddingToCart
                      ? const SizedBox(
                          height: 20,
                          width: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_cart,
                        ),

                  label: Text(
                    isAddingToCart
                        ? 'Adding...'
                        : 'Add to Cart',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}