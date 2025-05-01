import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    // Load products and categories when screen initializes
    context.read<ProductBloc>().add(const LoadProducts());
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Products')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ProductBloc>().add(
                              const LoadProducts(),
                            );
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<ProductBloc>().add(SearchProducts(query));
                }
              },
            ),
          ),

          // Categories
          SizedBox(
            height: 50,
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount:
                        state.categories.length + 1, // +1 for "All" category
                    itemBuilder: (context, index) {
                      // "All" category
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory.isEmpty,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = '';
                                });
                                context.read<ProductBloc>().add(
                                  const LoadProducts(),
                                );
                              }
                            },
                          ),
                        );
                      }

                      // Regular categories
                      final category = state.categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(category.name),
                          selected: _selectedCategory == category.name,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category.name;
                              });
                              context.read<ProductBloc>().add(
                                LoadProductsByCategory(category.name),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          // Products grid
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingIndicator();
                } else if (state is ProductLoaded ||
                    state is ProductsByCategoryLoaded ||
                    state is ProductSearchResultsLoaded) {
                  final products =
                      state is ProductLoaded
                          ? state.products
                          : state is ProductsByCategoryLoaded
                          ? (state as ProductsByCategoryLoaded).products
                          : (state as ProductSearchResultsLoaded).searchResults;

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          bool isInCart = false;

                          if (cartState is CartLoaded) {
                            isInCart = cartState.items.any(
                              (item) => item.product.name == product.name,
                            );
                          }

                          return BlocBuilder<FavoriteBloc, FavoriteState>(
                            builder: (context, favoriteState) {
                              bool isFavorite = false;

                              if (favoriteState is FavoriteLoaded) {
                                isFavorite = favoriteState.isFavorite(
                                  product.id,
                                );
                              }

                              return ProductCard(
                                product: product,
                                isInCart: isInCart,
                                isFavorite: isFavorite,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ProductDetailScreen(
                                            product: product,
                                          ),
                                    ),
                                  );
                                },
                                onAddToCart: () {
                                  if (isInCart) {
                                    context.read<CartBloc>().add(
                                      RemoveFromCart(product),
                                    );
                                  } else {
                                    context.read<CartBloc>().add(
                                      AddToCart(product),
                                    );
                                  }
                                },
                                onToggleFavorite: () {
                                  context.read<FavoriteBloc>().add(
                                    ToggleFavorite(product.id),
                                  );

                                  // Show confirmation message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFavorite
                                            ? AppLocalizations.of(
                                              context,
                                            ).translate(
                                              'removed_from_favorites',
                                            )
                                            : AppLocalizations.of(
                                              context,
                                            ).translate('added_to_favorites'),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                } else if (state is ProductError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<ProductBloc>().add(const LoadProducts());
                    },
                  );
                } else {
                  return const Center(child: Text('No products found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
