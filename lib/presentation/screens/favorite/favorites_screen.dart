import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/presentation/widgets/product_card.dart';
import 'package:app_3mcode_shop/presentation/widgets/loading_indicator.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('favorites'))),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('no_favorites'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.translate('add_products_to_favorites'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(localizations.translate('browse_products')),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final product = state.favorites[index];

                return BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    bool isInCart = false;
                    int quantity = 0;

                    if (cartState is CartLoaded) {
                      isInCart = cartState.items.any(
                        (item) => item.product.id == product.id,
                      );

                      if (isInCart) {
                        final cartItem = cartState.items.firstWhere(
                          (item) => item.product.id == product.id,
                        );
                        quantity = cartItem.quantity;
                      }
                    }

                    return ProductCard(
                      product: product,
                      isFavorite: true, // المنتج في المفضلة بالفعل
                      isInCart: isInCart,
                      quantity: quantity,
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
                        context.read<CartBloc>().add(AddToCart(product));
                      },
                      onIncrement:
                          isInCart
                              ? () {
                                context.read<CartBloc>().add(
                                  IncrementCartItemQuantity(product),
                                );
                              }
                              : null,
                      onDecrement:
                          isInCart
                              ? () {
                                context.read<CartBloc>().add(
                                  DecrementCartItemQuantity(product),
                                );
                              }
                              : null,
                      onToggleFavorite: () {
                        context.read<FavoriteBloc>().add(
                          RemoveFromFavorites(product.id),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (state is FavoriteError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
