import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import 'detail_screen.dart';
import 'users_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService =
      ProductService();

  final TextEditingController _searchController =
      TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _loadProducts();

    _searchController.addListener(
      _filterProducts,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products =
          await _productService.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where(
          (product) {
            return product.name
                    .toLowerCase()
                    .contains(query) ||
                product.description
                    .toLowerCase()
                    .contains(query);
          },
        ).toList();
      }
    });
  }

  Widget _buildProductsScreen(
    BuildContext context,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            8,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        )
                      : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildProductContent(context),
        ),
      ],
    );
  }

  Widget _buildProductContent(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 50,
                color: Theme.of(context)
                    .colorScheme
                    .error,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load products.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 56,
              ),
              SizedBox(height: 12),
              Text(
                'No products found.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          20,
        ),
        physics:
            const AlwaysScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (
          context,
          index,
        ) {
          final product =
              _filteredProducts[index];

          return _buildProductCard(
            context,
            product,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailScreen(
                product: product,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons
                            .image_not_supported_outlined,
                        size: 45,
                      ),
                    );
                  },
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress ==
                        null) {
                      return child;
                    }

                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(
    BuildContext context,
  ) {
    switch (_currentIndex) {
      case 0:
        return _buildProductsScreen(context);

      case 1:
        return const UsersScreen();

      case 2:
        return const SettingsScreen();

      default:
        return _buildProductsScreen(context);
    }
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Products';
      case 1:
        return 'Messages';
      case 2:
        return 'Settings';
      default:
        return 'E-Commerce App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
        ),
        centerTitle: true,
      ),
      body: _buildCurrentScreen(context),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.shopping_bag_outlined,
            ),
            selectedIcon: Icon(
              Icons.shopping_bag,
            ),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline,
            ),
            selectedIcon: Icon(
              Icons.chat_bubble,
            ),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
