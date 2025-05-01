import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/search/filter_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/loading_indicator.dart';
import 'package:app_3mcode_shop/presentation/widgets/error_view.dart';
import 'package:app_3mcode_shop/presentation/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 1000;
  RangeValues _currentRangeValues = const RangeValues(0, 1000);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('search')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(localizations),
          _buildFilters(localizations),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingIndicator();
                }

                if (state is ProductError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<ProductBloc>().add(const LoadProducts());
                    },
                  );
                }

                if (state is ProductLoaded ||
                    state is ProductFilterResultsLoaded) {
                  final products =
                      state is ProductLoaded
                          ? state.products
                          : (state as ProductFilterResultsLoaded)
                              .filteredProducts;

                  final filteredProducts =
                      products.where((product) {
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            product.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );

                        final price = double.parse(product.price);
                        final matchesPrice =
                            price >= _minPrice && price <= _maxPrice;

                        return matchesSearch && matchesPrice;
                      }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.translate('no_products_found'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, favoriteState) {
                          bool isFavorite = false;

                          if (favoriteState is FavoriteLoaded) {
                            isFavorite = favoriteState.isFavorite(product.id);
                          }

                          return ProductCard(
                            product: product,
                            isFavorite: isFavorite,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            onAddToCart: () {
                              // Add to cart functionality
                              context.read<CartBloc>().add(AddToCart(product));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations.translate(
                                      'item_added_to_cart',
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            onToggleFavorite: () {
                              context.read<FavoriteBloc>().add(
                                ToggleFavorite(product.id),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? localizations.translate(
                                          'removed_from_favorites',
                                        )
                                        : localizations.translate(
                                          'added_to_favorites',
                                        ),
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
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: localizations.translate('search_products'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilters(AppLocalizations localizations) {
    return ExpansionTile(
      title: Text(localizations.translate('filters')),
      leading: const Icon(Icons.filter_list),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('price_range'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_currentRangeValues.start.toInt()}'),
                  Text('\$${_currentRangeValues.end.toInt()}'),
                ],
              ),
              RangeSlider(
                values: _currentRangeValues,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: AppColors.primary,
                labels: RangeLabels(
                  '\$${_currentRangeValues.start.toInt()}',
                  '\$${_currentRangeValues.end.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(localizations.translate('apply_filters')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
