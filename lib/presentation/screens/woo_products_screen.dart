import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/repositories/product_repository.dart';
import 'package:app_3mcode_shop/presentation/widgets/product_card.dart';
import 'package:app_3mcode_shop/colors.dart';

class WooProductsScreen extends StatefulWidget {
  const WooProductsScreen({Key? key}) : super(key: key);

  @override
  State<WooProductsScreen> createState() => _WooProductsScreenState();
}

class _WooProductsScreenState extends State<WooProductsScreen> {
  final ProductRepository _productRepository = ProductRepository();
  late Future<List<ProductModel>> _productsFuture;
  String _searchQuery = '';
  String _selectedCategory = '';
  final List<String> _categories = [
    'City Bikes',
    'Mountain Bikes',
    'Road Bikes',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _productsFuture = _productRepository.searchProducts(_searchQuery);
      } else if (_selectedCategory.isNotEmpty) {
        _productsFuture = _productRepository.getProductsByCategory(
          _selectedCategory,
        );
      } else {
        _productsFuture = _productRepository.getProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WooCommerce Products'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found'));
                } else {
                  final products = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      print('🎴 Rendering product card for: ${product.name}');
                      print('🖼️ Product image: ${product.image}');

                      return ProductCard(
                        product: product,
                        onTap: () {
                          // Navigate to product detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: ${product.name}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onAddToCart: () {
                          // Add to cart
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to cart: ${product.name}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onToggleFavorite: () {
                          // Toggle favorite
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Toggled favorite: ${product.name}',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _selectedCategory = '';
          });
          _loadProducts();
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : '';
                  _searchQuery = '';
                });
                _loadProducts();
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.green.shade100,
              checkmarkColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}
