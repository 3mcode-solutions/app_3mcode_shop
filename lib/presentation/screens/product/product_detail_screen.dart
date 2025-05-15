import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app_3mcode_shop/colors.dart'; // TODO: Replace with AppTheme in the future
import 'package:app_3mcode_shop/data/models/models.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('product_details')),
        actions: [
          // Favorite button
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              bool isFavorite = false;

              if (state is FavoriteLoaded) {
                isFavorite = state.isFavorite(widget.product.id);
              }

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<FavoriteBloc>().add(
                    ToggleFavorite(widget.product.id),
                  );

                  // Show confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? AppLocalizations.of(
                              context,
                            ).translate('removed_from_favorites')
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
          ),

          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Show a simple share message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).translate('share_product'),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey.shade100,
                    child: Hero(
                      tag: 'product_image_${widget.product.name}',
                      child:
                          widget.product.image.startsWith('http')
                              ? CachedNetworkImage(
                                imageUrl: widget.product.image,
                                fit: BoxFit.contain,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) =>
                                        const Center(child: Icon(Icons.error)),
                              )
                              : Image.asset(
                                widget.product.image,
                                fit: BoxFit.contain,
                              ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Rating
                        Row(
                          children: [
                            Image.asset("assets/icons/star.png", width: 20),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.product.rate} (${widget.product.rateCount} reviews)",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Price
                        Row(
                          children: [
                            Text(
                              "\$${widget.product.discountedPriceString}",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "\$${widget.product.price}",
                              style: TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "20% OFF",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Quantity selector
                        Row(
                          children: [
                            const Text(
                              "Quantity:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Decrement button
                                  IconButton(
                                    onPressed: _decrementQuantity,
                                    icon: const Icon(Icons.remove),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),

                                  // Quantity
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        right: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  // Increment button
                                  IconButton(
                                    onPressed: _incrementQuantity,
                                    icon: const Icon(Icons.add),
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Description
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                          "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                          "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris "
                          "nisi ut aliquip ex ea commodo consequat.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Specifications
                        const Text(
                          "Specifications",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        _buildSpecificationItem("Weight", "500g"),
                        _buildSpecificationItem("Category", "Fruits"),
                        _buildSpecificationItem("Origin", "Local Farm"),
                        _buildSpecificationItem("Packaging", "Eco-friendly"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar with add to cart button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Total Price",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "\$${(widget.product.discountedPrice * quantity).toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add to cart button
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, state) {
                    bool isInCart = false;
                    bool isLoading = state is CartLoading;

                    if (state is CartLoaded) {
                      isInCart = state.items.any(
                        (item) => item.product.name == widget.product.name,
                      );
                    }

                    return ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                if (isInCart) {
                                  context.read<CartBloc>().add(
                                    RemoveFromCart(widget.product),
                                  );
                                } else {
                                  context.read<CartBloc>().add(
                                    AddToCart(
                                      widget.product,
                                      quantity: quantity,
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isInCart ? Colors.red : AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                isInCart ? "Remove from Cart" : "Add to Cart",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
