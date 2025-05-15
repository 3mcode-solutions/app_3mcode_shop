import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/models/woo_models/woo_product_model.dart';
import 'package:app_3mcode_shop/data/services/cache_service.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class ProductRepository {
  // Singleton pattern
  static final ProductRepository _instance = ProductRepository._internal();

  factory ProductRepository() {
    return _instance;
  }

  final WooCommerceService _wooCommerceService = WooCommerceService();
  final CacheService _cacheService = CacheService();
  final String _productsBoxName = 'products';

  ProductRepository._internal();

  /// Get all products
  ///
  /// Fetches products from WooCommerce API or local storage if offline
  Future<List<ProductModel>> getProducts({bool forceRefresh = false}) async {
    try {
      // Use cache service to get or fetch data
      final cacheKey = 'products';

      return await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch products from WooCommerce API
          final wooProducts = await _wooCommerceService.getProducts(
            perPage: 50,
          );

          // Convert to app models
          final products =
              wooProducts.map((product) {
                // Create WooProduct from Map
                final wooProduct = WooProduct(
                  id: product['id'] as int,
                  name: product['name'] as String,
                  price: product['price'] as String? ?? '0',
                  categories:
                      (product['categories'] as List<dynamic>?)
                          ?.map(
                            (e) => WooProductCategory.fromJson(
                              e as Map<String, dynamic>,
                            ),
                          )
                          .toList() ??
                      [],
                  images:
                      (product['images'] as List<dynamic>?)
                          ?.map(
                            (e) => WooProductImage.fromJson(
                              e as Map<String, dynamic>,
                            ),
                          )
                          .toList() ??
                      [],
                  description: product['description'] as String?,
                  shortDescription: product['short_description'] as String?,
                  sku: product['sku'] as String?,
                  regularPrice: product['regular_price'] as String?,
                  salePrice: product['sale_price'] as String?,
                  onSale: product['on_sale'] as bool?,
                  averageRating: product['average_rating'] as String?,
                  ratingCount: product['rating_count'] as int?,
                );
                return ProductModel.fromWooProduct(wooProduct);
              }).toList();

          // Save products locally for offline use
          await _saveProductsLocally(products);

          return products;
        },
      );
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      // Fallback to local data in case of error
      return await _getLocalProducts();
    }
  }

  /// Save products to local storage
  Future<void> _saveProductsLocally(List<ProductModel> products) async {
    try {
      final box = await Hive.openBox<Map>(_productsBoxName);

      // Convert products to maps
      final productMaps =
          products
              .map(
                (product) => {
                  'id': product.id,
                  'name': product.name,
                  'description': product.description,
                  'price': product.price,
                  'image': product.image,
                  'category': product.category,
                  'isOnSale': product.isOnSale,
                  'discountPercentage': product.discountPercentage,
                  'rate': product.rate,
                  'rateCount': product.rateCount,
                  'images': product.images,
                  'attributes': product.attributes,
                  'variations': product.variations,
                },
              )
              .toList();

      // Clear existing data and save new data
      await box.clear();
      for (var productMap in productMaps) {
        await box.add(productMap);
      }
    } catch (e) {
      debugPrint('Error saving products locally: $e');
    }
  }

  /// Get products from local storage
  Future<List<ProductModel>> _getLocalProducts() async {
    try {
      final box = await Hive.openBox<Map>(_productsBoxName);

      if (box.isEmpty) {
        // Fallback to hardcoded data if no local data
        return LocalData.getProducts();
      }

      // Convert maps to models
      return box.values
          .map(
            (productMap) => ProductModel(
              id: productMap['id'] as String,
              name: productMap['name'] as String,
              description: productMap['description'] as String?,
              price: productMap['price'] as String,
              image: productMap['image'] as String,
              category: productMap['category'] as String? ?? '',
              isOnSaleFlag: productMap['isOnSale'] as bool? ?? false,
              discountPercentage:
                  productMap['discountPercentage'] as String? ?? '0',
              rate: productMap['rate'] as String,
              rateCount: productMap['rateCount'] as String,
              images: List<String>.from(productMap['images'] ?? []),
              attributes: List<Map<String, dynamic>>.from(
                productMap['attributes'] ?? [],
              ),
              variations: List<Map<String, dynamic>>.from(
                productMap['variations'] ?? [],
              ),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting products from local storage: $e');
      // Fallback to hardcoded data in case of error
      return LocalData.getProducts();
    }
  }

  /// Get product by name
  ///
  /// Returns null if product not found
  Future<ProductModel?> getProductByName(String name) async {
    final products = await getProducts();

    try {
      return products.firstWhere(
        (product) => product.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search products by name
  ///
  /// Returns empty list if no products found
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return getProducts();
    }

    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Search using WooCommerce API
        final wooProducts = await _wooCommerceService.getProducts(
          search: query,
        );

        // Convert to app models
        return wooProducts
            .map(
              (product) => ProductModel.fromWooProduct(product as WooProduct),
            )
            .toList();
      } else {
        // Search in local data if offline
        final products = await _getLocalProducts();
        final lowercaseQuery = query.toLowerCase();

        return products
            .where(
              (product) => product.name.toLowerCase().contains(lowercaseQuery),
            )
            .toList();
      }
    } catch (e) {
      // Fallback to local search in case of error
      final products = await _getLocalProducts();
      final lowercaseQuery = query.toLowerCase();

      return products
          .where(
            (product) => product.name.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    }
  }

  /// Get featured products
  ///
  /// Returns a subset of products for featured section
  Future<List<ProductModel>> getFeaturedProducts() async {
    final products = await getProducts();

    // For demo purposes, just return the first 5 products
    return products.take(5).toList();
  }

  /// Get products by category
  ///
  /// Returns products that belong to the specified category
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Get products by category using WooCommerce API
        final wooProducts = await _wooCommerceService.getProducts(
          category: categoryName,
        );

        // Convert to app models
        return wooProducts
            .map(
              (product) => ProductModel.fromWooProduct(product as WooProduct),
            )
            .toList();
      } else {
        // Filter local data if offline
        final products = await _getLocalProducts();
        final lowercaseCategoryName = categoryName.toLowerCase();

        return products
            .where(
              (product) =>
                  product.category.toLowerCase() == lowercaseCategoryName,
            )
            .toList();
      }
    } catch (e) {
      // Fallback to local filtering in case of error
      final products = await _getLocalProducts();
      final lowercaseCategoryName = categoryName.toLowerCase();

      return products
          .where(
            (product) =>
                product.category.toLowerCase() == lowercaseCategoryName,
          )
          .toList();
    }
  }

  /// Get products by category ID
  ///
  /// Returns products that belong to the specified category ID
  Future<List<ProductModel>> getProductsByCategoryId(String categoryId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Get products by category ID using WooCommerce API
        final wooProducts = await _wooCommerceService.getProducts(
          categoryId: categoryId,
        );

        // Convert to app models
        return wooProducts
            .map(
              (product) => ProductModel.fromWooProduct(product as WooProduct),
            )
            .toList();
      } else {
        // Filter local data if offline
        final products = await _getLocalProducts();

        // In offline mode, we don't have category IDs in the local data
        // So we'll return an empty list or all products depending on the use case
        return products;
      }
    } catch (e) {
      debugPrint('❌ Error getting products by category ID: $e');
      // Fallback to all products in case of error
      return await _getLocalProducts();
    }
  }
}
