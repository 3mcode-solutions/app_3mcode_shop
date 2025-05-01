import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';

enum ProductListType { discounted, bestSelling, seasonal, discoverMore }

class ProductListScreen extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final ProductListType type;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.products,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // فلتر المنتجات (اختياري)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: localizations.translate('search_products'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // عرض خيارات الفلترة
                  },
                ),
              ],
            ),
          ),

          // عرض المنتجات
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          isFavorite = favoriteState.isFavorite(product.id);
                        }

                        return Stack(
                          children: [
                            ProductCard(
                              product: product,
                              isInCart: isInCart,
                              isFavorite: isFavorite,
                              quantity:
                                  isInCart && cartState is CartLoaded
                                      ? cartState.items
                                          .firstWhere(
                                            (item) =>
                                                item.product.name ==
                                                product.name,
                                            orElse:
                                                () => CartItemModel(
                                                  product: product,
                                                ),
                                          )
                                          .quantity
                                      : 0,
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
                                if (!isInCart) {
                                  context.read<CartBloc>().add(
                                    AddToCart(product),
                                  );
                                }
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
                                // حفظ حالة المفضلة الحالية
                                final currentFavoriteState = favoriteState;
                                final wasInFavorites =
                                    currentFavoriteState is FavoriteLoaded &&
                                    currentFavoriteState.isFavorite(product.id);

                                // تأثير حركي للأيقونة (تكبير وتصغير)
                                AnimatedFavoriteIcon.playAnimation(context);

                                // إضافة/إزالة من المفضلة
                                context.read<FavoriteBloc>().add(
                                  ToggleFavorite(product.id),
                                );

                                // عرض رسالة تأكيد
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      wasInFavorites
                                          ? localizations.translate(
                                            'removed_from_favorites',
                                          )
                                          : localizations.translate(
                                            'added_to_favorites',
                                          ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.primary,
                                    action: SnackBarAction(
                                      label: localizations.translate('ok'),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            // إضافة الشارات المناسبة حسب نوع القائمة
                            if (type == ProductListType.discounted)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "20% OFF",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (type == ProductListType.bestSelling)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "BEST SELLER",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            if (type == ProductListType.seasonal)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "SEASONAL",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
