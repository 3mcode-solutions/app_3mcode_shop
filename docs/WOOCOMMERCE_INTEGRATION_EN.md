# 3MCode Shop Integration with WooCommerce

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

## Overview

This document outlines how to integrate the existing 3MCode Shop Flutter application with the WooCommerce store available at [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/). The goal is to use the application as an interface to display products, details, shopping cart, coupons, and all features available in the e-commerce store.

## E-commerce Store Analysis

### Current Store
- **Platform**: WordPress with WooCommerce
- **URL**: [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/)
- **Products**: Electric bikes categorized into different types (City Bikes, Mountain Bikes, Road Bikes)
- **Features**:
  - Product display
  - Filtering by price, color, and category
  - Shopping cart
  - Wishlist
  - Product comparison
  - Product options (colors)
  - Related products
  - Ratings and reviews

## Integration Requirements

1. **API**: Use WooCommerce REST API to access store data
2. **Authentication**: Set up API keys for secure data access
3. **Data Synchronization**: Update app data with the e-commerce store
4. **Local Storage**: Store data locally for offline use
5. **Login**: Support login using e-commerce store accounts

## Technical Solution

### 1. Setting up WooCommerce REST API

#### 1.1 Creating API Keys

1. Log in to WordPress admin panel
2. Navigate to WooCommerce > Settings > Advanced > REST API
3. Create a new key with appropriate permissions:
   - `read` - for read-only access
   - `write` - for read and write access
   - `read_write` - for full access

```
Required permission level: read_write
```

#### 1.2 Securely Storing API Keys

API keys should be stored securely and not directly included in the application code:

```dart
// Use a secure configuration file or secure storage service
// Do not include these keys directly in your application code
// Use a .env file or Flutter Secure Storage
final Map<String, String> apiKeys = {
  'consumerKey': 'ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa',
  'consumerSecret': 'cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa',
};
```

### 2. Adding WooCommerce Integration Libraries

#### 2.1 Update pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Existing libraries...

  # WooCommerce libraries
  woocommerce: ^0.9.7
  # or
  woocommerce_api: ^0.1.0

  # Additional libraries
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  connectivity_plus: ^5.0.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

#### 2.2 Creating WooCommerce API Service

```dart
// lib/data/services/woocommerce_service.dart
import 'package:woocommerce/woocommerce.dart';

class WooCommerceService {
  late WooCommerce _wooCommerce;

  // Singleton pattern
  static final WooCommerceService _instance = WooCommerceService._internal();

  factory WooCommerceService() {
    return _instance;
  }

  WooCommerceService._internal() {
    _initWooCommerce();
  }

  void _initWooCommerce() {
    _wooCommerce = WooCommerce(
      baseUrl: 'https://shop.3mcode-solutions.com',
      consumerKey: 'ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa',
      consumerSecret: 'cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa',
      isDebug: false,
    );
  }

  // Get products
  Future<List<WooProduct>> getProducts({
    int? page,
    int? perPage,
    String? category,
    String? search,
  }) async {
    return await _wooCommerce.getProducts(
      page: page,
      perPage: perPage,
      category: category,
      search: search,
    );
  }

  // Get product categories
  Future<List<WooProductCategory>> getCategories() async {
    return await _wooCommerce.getProductCategories();
  }

  // Get product details
  Future<WooProduct> getProduct(int id) async {
    return await _wooCommerce.getProductById(id: id);
  }

  // Add product to cart
  Future<bool> addToCart(int productId, int quantity) async {
    return await _wooCommerce.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }

  // Get cart contents
  Future<List<WooCartItem>> getCart() async {
    return await _wooCommerce.getCart();
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity(
    String key,
    int quantity,
  ) async {
    return await _wooCommerce.updateCartItemQuantity(
      key: key,
      quantity: quantity,
    );
  }

  // Remove item from cart
  Future<bool> removeCartItem(String key) async {
    return await _wooCommerce.removeCartItem(key: key);
  }

  // Login
  Future<WooCustomer?> login(String username, String password) async {
    return await _wooCommerce.loginCustomer(
      username: username,
      password: password,
    );
  }

  // Create new account
  Future<WooCustomer> createCustomer(WooCustomerCreate customer) async {
    return await _wooCommerce.createCustomer(customer);
  }

  // Get coupons
  Future<List<WooCoupon>> getCoupons() async {
    return await _wooCommerce.getCoupons();
  }

  // Apply coupon
  Future<bool> applyCoupon(String code) async {
    return await _wooCommerce.applyCoupon(code: code);
  }

  // Create order
  Future<WooOrder> createOrder(WooOrderPayload orderPayload) async {
    return await _wooCommerce.createOrder(orderPayload);
  }
}
```

### 3. Modifying Data Models

#### 3.1 Converting Product Model

```dart
// lib/data/models/product_model.dart
import 'package:equatable/equatable.dart';
import 'package:woocommerce/models/products.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final String category;
  final bool isOnSale;
  final String discountPercentage;
  final String rate;
  final String rateCount;
  final List<String> images;
  final List<Map<String, dynamic>> attributes;
  final List<Map<String, dynamic>> variations;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isOnSale = false,
    this.discountPercentage = '0',
    this.rate = '0',
    this.rateCount = '0',
    this.images = const [],
    this.attributes = const [],
    this.variations = const [],
  });

  // Convert from WooProduct to ProductModel
  factory ProductModel.fromWooProduct(WooProduct product) {
    return ProductModel(
      id: product.id.toString(),
      name: product.name ?? '',
      description: product.description ?? '',
      price: product.price ?? '0',
      image: product.images?.isNotEmpty == true
          ? product.images!.first.src ?? ''
          : '',
      category: product.categories?.isNotEmpty == true
          ? product.categories!.first.name ?? ''
          : '',
      isOnSale: product.onSale ?? false,
      discountPercentage: _calculateDiscountPercentage(
        product.regularPrice,
        product.salePrice,
      ),
      rate: product.averageRating ?? '0',
      rateCount: product.ratingCount?.toString() ?? '0',
      images: product.images
              ?.map((image) => image.src ?? '')
              .toList() ??
          [],
      attributes: product.attributes
              ?.map((attr) => {
                    'name': attr.name,
                    'options': attr.options,
                  })
              .toList() ??
          [],
      variations: product.variations
              ?.map((variation) => {
                    'id': variation,
                  })
              .toList() ??
          [],
    );
  }

  // Calculate discount percentage
  static String _calculateDiscountPercentage(
    String? regularPrice,
    String? salePrice,
  ) {
    if (regularPrice == null ||
        salePrice == null ||
        regularPrice.isEmpty ||
        salePrice.isEmpty) {
      return '0';
    }

    final regular = double.tryParse(regularPrice) ?? 0;
    final sale = double.tryParse(salePrice) ?? 0;

    if (regular <= 0 || sale <= 0 || sale >= regular) {
      return '0';
    }

    final discount = ((regular - sale) / regular) * 100;
    return discount.toStringAsFixed(0);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        image,
        category,
        isOnSale,
        discountPercentage,
        rate,
        rateCount,
        images,
        attributes,
        variations,
      ];
}
```

### 4. Modifying Repositories

#### 4.1 Updating Product Repository

```dart
// lib/data/repositories/product_repository.dart
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';
import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class ProductRepository {
  final WooCommerceService _wooCommerceService = WooCommerceService();
  final String _productsBoxName = 'products';

  // Singleton pattern
  static final ProductRepository _instance = ProductRepository._internal();

  factory ProductRepository() {
    return _instance;
  }

  ProductRepository._internal();

  /// Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;

      if (hasInternet) {
        // Get data from API
        final wooProducts = await _wooCommerceService.getProducts(
          perPage: 50,
        );

        // Convert data to app model
        final products = wooProducts
            .map((product) => ProductModel.fromWooProduct(product))
            .toList();

        // Store data locally
        await _saveProductsLocally(products);

        return products;
      } else {
        // Retrieve locally stored data
        return await _getLocalProducts();
      }
    } catch (e) {
      // In case of error, retrieve locally stored data
      return await _getLocalProducts();
    }
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return getProducts();
    }

    try {
      final wooProducts = await _wooCommerceService.getProducts(
        search: query,
      );

      return wooProducts
          .map((product) => ProductModel.fromWooProduct(product))
          .toList();
    } catch (e) {
      // Search in locally stored data
      final products = await _getLocalProducts();
      final lowercaseQuery = query.toLowerCase();

      return products
          .where((product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    }
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      final wooProducts = await _wooCommerceService.getProducts(
        category: categoryName,
      );

      return wooProducts
          .map((product) => ProductModel.fromWooProduct(product))
          .toList();
    } catch (e) {
      // Search in locally stored data
      final products = await _getLocalProducts();

      return products
          .where((product) =>
              product.category.toLowerCase() == categoryName.toLowerCase())
          .toList();
    }
  }

  /// Store products locally
  Future<void> _saveProductsLocally(List<ProductModel> products) async {
    final box = await Hive.openBox<Map>(_productsBoxName);

    // Convert products to maps
    final productMaps = products.map((product) => {
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
    }).toList();

    // Save data
    await box.clear();
    for (var productMap in productMaps) {
      await box.add(productMap);
    }
  }

  /// Retrieve locally stored products
  Future<List<ProductModel>> _getLocalProducts() async {
    final box = await Hive.openBox<Map>(_productsBoxName);

    if (box.isEmpty) {
      return [];
    }

    // Convert maps to models
    return box.values.map((productMap) => ProductModel(
      id: productMap['id'] as String,
      name: productMap['name'] as String,
      description: productMap['description'] as String,
      price: productMap['price'] as String,
      image: productMap['image'] as String,
      category: productMap['category'] as String,
      isOnSale: productMap['isOnSale'] as bool,
      discountPercentage: productMap['discountPercentage'] as String,
      rate: productMap['rate'] as String,
      rateCount: productMap['rateCount'] as String,
      images: List<String>.from(productMap['images'] ?? []),
      attributes: List<Map<String, dynamic>>.from(productMap['attributes'] ?? []),
      variations: List<Map<String, dynamic>>.from(productMap['variations'] ?? []),
    )).toList();
  }
}
```

## Implementation Steps

### 1. Environment Setup

1. Update `pubspec.yaml` with required libraries
2. Install libraries: `flutter pub get`
3. Set up Hive for local storage:
   ```dart
   // In main.dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Hive.initFlutter();
     runApp(const App());
   }
   ```

### 2. Implementing Services and Repositories

1. Create WooCommerce API service
2. Update data models
3. Modify repositories to use API

### 3. Updating User Interface

1. Modify product display screens
2. Update product detail screen to show options and multiple images
3. Modify shopping cart to integrate with WooCommerce

### 4. Testing Integration

1. Test API connection
2. Test product and category display
3. Test shopping cart and orders
4. Test offline mode

## Conclusion

The 3MCode Shop application can be easily integrated with the WooCommerce store using the WooCommerce REST API. This integration will allow the application to display all products, details, and features available in the e-commerce store, while maintaining a smooth user experience and good performance.

---

<p align="center">
  Developed by <a href="https://www.3mcode.com">3MCode</a> - All rights reserved © 2025
</p>
