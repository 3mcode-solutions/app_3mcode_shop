import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app_3mcode_shop/core/constants/assets_paths.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: Row(
          children: [
            SvgPicture.asset(AssetPaths.motorIcon),
            const SizedBox(width: 10),
            const Text("61 Hopper street..", style: TextStyle(fontSize: 19)),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 34),
            const Spacer(),
            SvgPicture.asset(AssetPaths.basketIcon),
          ],
        ),
      ),
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
                items: banners.map((banner) {
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
                          child: Image.asset(
                            banner,
                            fit: BoxFit.cover,
                          ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                          final isSelected = state.selectedCategory?.name == category.name;
                          
                          return CategoryItem(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<CategoryBloc>().add(SelectCategory(category.name));
                              context.read<ProductBloc>().add(LoadProductsByCategory(category.name));
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              SizedBox(
                height: 250,
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductLoaded || state is ProductsByCategoryLoaded) {
                      final products = state is ProductLoaded 
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
                                  (item) => item.product.name == product.name
                                );
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ProductCard(
                                  product: product,
                                  isInCart: isInCart,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(product: product),
                                      ),
                                    );
                                  },
                                  onAddToCart: () {
                                    if (isInCart) {
                                      context.read<CartBloc>().add(RemoveFromCart(product));
                                    } else {
                                      context.read<CartBloc>().add(AddToCart(product));
                                    }
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                (item) => item.product.name == product.name
                              );
                            }
                            
                            return ProductCard(
                              product: product,
                              isInCart: isInCart,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              onAddToCart: () {
                                if (isInCart) {
                                  context.read<CartBloc>().add(RemoveFromCart(product));
                                } else {
                                  context.read<CartBloc>().add(AddToCart(product));
                                }
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
            ],
          ),
        ),
      ),
    );
  }
}
