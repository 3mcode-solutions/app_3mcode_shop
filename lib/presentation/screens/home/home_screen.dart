import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/constants/assets_paths.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/cart/cart_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/auth/login_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/account/profile_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/favorite/favorites_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_list_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/settings/theme_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> banners = LocalData.getBanners();

  @override
  void initState() {
    super.initState();
    // Load products and categories when screen initializes
    context.read<ProductBloc>().add(const LoadProducts());
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  Widget _buildUserAvatar(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;
        final user = isAuthenticated ? state.user : null;

        return GestureDetector(
          onTap: () {
            if (isAuthenticated && user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: user),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                isAuthenticated && user != null && user.photoUrl != null
                    ? _getProfileImage(user.photoUrl!)
                    : null,
            child:
                (isAuthenticated && user != null && user.photoUrl != null)
                    ? null
                    : Icon(
                      Icons.person,
                      size: 20,
                      color: isAuthenticated ? AppColors.primary : Colors.grey,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildCartIcon(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int itemCount = 0;

        if (state is CartLoaded) {
          itemCount = state.items.length;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(AssetPaths.basketIcon),
              if (itemCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      itemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteIcon(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        int favoriteCount = 0;

        if (state is FavoriteLoaded) {
          favoriteCount = state.favorites.length;
        }

        return AnimatedFavoriteIcon(
          favoriteCount: favoriteCount,
          onTap: () {
            // حفظ مرجع للسياق الحالي
            final currentContext = context;

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            ).then((_) {
              // التحقق من أن السياق لا يزال صالحًا
              if (currentContext.mounted) {
                // عرض رسالة تأكيد بعد العودة من شاشة المفضلة
                final localizations = AppLocalizations.of(currentContext);
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  SnackBar(
                    content: Text(localizations.translate('favorites_viewed')),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                    action: SnackBarAction(
                      label: localizations.translate('ok'),
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(
                          currentContext,
                        ).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            });
          },
        );
      },
    );
  }

  ImageProvider _getProfileImage(String photoUrl) {
    if (photoUrl.startsWith('/')) {
      return FileImage(File(photoUrl));
    } else {
      return NetworkImage(photoUrl);
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الصفحة الرئيسية'),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة الجانبية
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('الفئات'),
            onTap: () {
              Navigator.pop(context);
              // يمكن إضافة التنقل إلى صفحة الفئات هنا
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('المفضلة'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('سلة التسوق'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('حسابي'),
            onTap: () {
              Navigator.pop(context);
              // التحقق مما إذا كان المستخدم مسجل دخول
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: authState.user),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDarkMode =
                  state is ThemeLoaded ? state.isDarkMode : false;
              return ListTile(
                leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                title: Text(isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن'),
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    context.read<ThemeBloc>().add(const ToggleTheme());
                  },
                ),
                onTap: () {
                  context.read<ThemeBloc>().add(const ToggleTheme());
                },
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // عرض مربع حوار للتأكيد
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('تسجيل الخروج'),
                            content: const Text(
                              'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthBloc>().add(
                                    const LogoutUser(),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('تسجيل الخروج'),
                              ),
                            ],
                          ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is Authenticated;
        final user = isAuthenticated ? (state as Authenticated).user : null;

        return DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage:
                    isAuthenticated && user != null && user.photoUrl != null
                        ? _getProfileImage(user.photoUrl!)
                        : null,
                child:
                    (isAuthenticated && user != null && user.photoUrl != null)
                        ? null
                        : const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
              ),
              const SizedBox(height: 10),
              Text(
                isAuthenticated && user != null ? user.name : 'مرحبًا بك!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isAuthenticated && user != null
                    ? user.email
                    : 'تسجيل الدخول للوصول إلى جميع الميزات',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: Row(
          children: [
            const Text(
              "3M Shop",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            _buildUserAvatar(context),
            const SizedBox(width: 16),
            _buildFavoriteIcon(context),
            const SizedBox(width: 16),
            _buildCartIcon(context),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(const LoadProducts());
          context.read<CategoryBloc>().add(const LoadCategories());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
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
                      // Navigate to search results screen
                      // This would be implemented in a real app
                    }
                  },
                ),
              ),

              // Banner slider
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  viewportFraction: 0.92,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                ),
                items:
                    banners.map((banner) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(banner, fit: BoxFit.cover),
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Categories
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CategoryLoaded) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          final isSelected =
                              state.selectedCategory?.name == category.name;

                          return CategoryItem(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<CategoryBloc>().add(
                                SelectCategory(category.name),
                              );
                              context.read<ProductBloc>().add(
                                LoadProductsByCategory(category.name),
                              );
                            },
                          );
                        },
                      );
                    } else if (state is CategoryError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else {
                      return const Center(child: Text('No categories found'));
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Featured Products
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Featured Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductLoaded ||
                        state is ProductsByCategoryLoaded) {
                      final products =
                          state is ProductLoaded
                              ? state.products
                              : (state as ProductsByCategoryLoaded).products;

                      return BlocBuilder<CartBloc, CartState>(
                        builder: (context, cartState) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              bool isInCart = false;

                              if (cartState is CartLoaded) {
                                isInCart = cartState.items.any(
                                  (item) => item.product.name == product.name,
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: BlocBuilder<FavoriteBloc, FavoriteState>(
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
                                      quantity:
                                          isInCart && cartState is CartLoaded
                                              ? (cartState as CartLoaded).items
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
                                                (context) =>
                                                    ProductDetailScreen(
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
                                                  IncrementCartItemQuantity(
                                                    product,
                                                  ),
                                                );
                                              }
                                              : null,
                                      onDecrement:
                                          isInCart
                                              ? () {
                                                context.read<CartBloc>().add(
                                                  DecrementCartItemQuantity(
                                                    product,
                                                  ),
                                                );
                                              }
                                              : null,
                                      onToggleFavorite: () {
                                        context.read<FavoriteBloc>().add(
                                          ToggleFavorite(product.id),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else if (state is ProductError) {
                      return Center(child: Text('Error: ${state.message}'));
                    } else {
                      return const Center(child: Text('No products found'));
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Popular Products
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Popular Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductLoaded) {
                    // For demo purposes, just show the same products in a grid
                    final popularProducts = state.products.take(6).toList();

                    return BlocBuilder<CartBloc, CartState>(
                      builder: (context, cartState) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: popularProducts.length,
                          itemBuilder: (context, index) {
                            final product = popularProducts[index];
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
                                              IncrementCartItemQuantity(
                                                product,
                                              ),
                                            );
                                          }
                                          : null,
                                  onDecrement:
                                      isInCart
                                          ? () {
                                            context.read<CartBloc>().add(
                                              DecrementCartItemQuantity(
                                                product,
                                              ),
                                            );
                                          }
                                          : null,
                                  onToggleFavorite: () {
                                    context.read<FavoriteBloc>().add(
                                      ToggleFavorite(product.id),
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
                    return Center(child: Text('Error: ${state.message}'));
                  } else {
                    return const Center(child: Text('No products found'));
                  }
                },
              ),

              const SizedBox(height: 20),

              // منتجات مخفضة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('discounted_products'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductListScreen(
                                  title: AppLocalizations.of(
                                    context,
                                  ).translate('discounted_products'),
                                  products: LocalData.getDiscountedProducts(),
                                  type: ProductListType.discounted,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('see_all'),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: _buildProductHorizontalList(
                  context: context,
                  products: LocalData.getDiscountedProducts(),
                  showDiscountBadge: true,
                ),
              ),

              const SizedBox(height: 20),

              // الأكثر مبيعًا
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('best_selling'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductListScreen(
                                  title: AppLocalizations.of(
                                    context,
                                  ).translate('best_selling'),
                                  products: LocalData.getBestSellingProducts(),
                                  type: ProductListType.bestSelling,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('see_all'),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: _buildProductHorizontalList(
                  context: context,
                  products: LocalData.getBestSellingProducts(),
                  showBestSellerBadge: true,
                ),
              ),

              const SizedBox(height: 20),

              // منتجات موسمية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).translate('seasonal_products'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductListScreen(
                                  title: AppLocalizations.of(
                                    context,
                                  ).translate('seasonal_products'),
                                  products: LocalData.getSeasonalProducts(),
                                  type: ProductListType.seasonal,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('see_all'),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: _buildProductHorizontalList(
                  context: context,
                  products: LocalData.getSeasonalProducts(),
                  showSeasonalBadge: true,
                ),
              ),

              const SizedBox(height: 20),

              // اكتشف المزيد
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('discover_more'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductListScreen(
                                  title: AppLocalizations.of(
                                    context,
                                  ).translate('discover_more'),
                                  products: LocalData.getDiscoverMoreProducts(),
                                  type: ProductListType.discoverMore,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context).translate('see_all'),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: _buildProductHorizontalList(
                  context: context,
                  products: LocalData.getDiscoverMoreProducts(),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductHorizontalList({
    required BuildContext context,
    required List<ProductModel> products,
    bool showDiscountBadge = false,
    bool showBestSellerBadge = false,
    bool showSeasonalBadge = false,
  }) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            bool isInCart = false;

            if (cartState is CartLoaded) {
              isInCart = cartState.items.any(
                (item) => item.product.name == product.name,
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BlocBuilder<FavoriteBloc, FavoriteState>(
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
                                          item.product.name == product.name,
                                      orElse:
                                          () => CartItemModel(product: product),
                                    )
                                    .quantity
                                : 0,
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
                          if (!isInCart) {
                            context.read<CartBloc>().add(AddToCart(product));
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
                          context.read<FavoriteBloc>().add(
                            ToggleFavorite(product.id),
                          );
                        },
                      ),
                      if (showDiscountBadge)
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
                      if (showBestSellerBadge)
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
                      if (showSeasonalBadge)
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
              ),
            );
          },
        );
      },
    );
  }
}
