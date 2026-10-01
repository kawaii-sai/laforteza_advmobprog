import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/cart.dart';
import 'detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              );
            },
          ),
        ],
      ),

      body: cartProvider.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,

                    itemBuilder: (context, index) {
                      final item =
                          cartProvider.items[index];

                      return _buildCartItem(
                        context,
                        item,
                      );
                    },
                  ),
                ),

                _buildOrderSummary(
                  context,
                  cartProvider,
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'Your cart is empty',

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Add some products to get started!',
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/home',
              );
            },

            child: const Text(
              'Continue Shopping',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartProduct item,
  ) {
    final cartProvider =
        context.read<CartProvider>();

    return Card(
      elevation: 3,

      margin:
          const EdgeInsets.only(bottom: 15),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),

        onTap: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) => DetailScreen(
                cartProduct: item,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,

                child: item.thumbnail.isNotEmpty
                    ? Image.network(
                        item.thumbnail,
                        fit: BoxFit.cover,

                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                      ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      item.title,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '\$${item.price.toStringAsFixed(2)}',

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${item.quantity} item(s) • \$${item.total.toStringAsFixed(2)} total',

                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      cartProvider.increaseQuantity(
                        item.id,
                      );
                    },

                    icon: const Icon(
                      Icons.add_circle,
                    ),
                  ),

                  Text(
                    '${item.quantity}',

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      cartProvider.decreaseQuantity(
                        item.id,
                      );
                    },

                    icon: const Icon(
                      Icons.remove_circle_outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Subtotal:',

                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                Text(
                  '\$${cartProvider.subtotal.toStringAsFixed(2)}',

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Total Items:',
                ),

                Text(
                  '${cartProvider.totalItems}',
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {
                  _confirmOrder(
                    context,
                    cartProvider,
                  );
                },

                child: const Text(
                  'Confirm Order',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirm Order',
          ),

          content: Text(
            'Are you sure you want to confirm your order with ${cartProvider.totalItems} item(s)?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                cartProvider.confirmOrder();

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🎉 Order confirmed successfully!',
                    ),
                  ),
                );
              },

              child: const Text(
                'Confirm',
              ),
            ),
          ],
        );
      },
    );
  }
}