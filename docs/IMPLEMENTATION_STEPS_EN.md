# Implementation Steps for 3MCode Shop Integration with WooCommerce

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

## Introduction

This document outlines the practical steps for implementing the integration of the 3MCode Shop application with the WooCommerce store available at [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/). The necessary API keys have been created and are ready for use.

## Prerequisites

1. Flutter SDK installed and development environment set up
2. Access to the existing 3MCode Shop application project
3. Access to the WordPress admin panel for the e-commerce store
4. API keys that have been created:
   - Consumer Key: `ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa`
   - Consumer Secret: `cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa`

## Implementation Steps

### 1. Update pubspec.yaml

Add the necessary libraries for WooCommerce integration:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Existing libraries...
  
  # WooCommerce libraries
  woocommerce: ^0.9.7
  
  # Additional libraries
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  connectivity_plus: ^5.0.2
  flutter_secure_storage: ^9.0.0
  flutter_dotenv: ^5.1.0
```

Then install the libraries:

```bash
flutter pub get
```

### 2. Set Up Secure Storage for Keys

#### 2.1 Create .env File

Create a `.env` file in the project root:

```
WOOCOMMERCE_URL=https://shop.3mcode-solutions.com
WOOCOMMERCE_CONSUMER_KEY=ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa
WOOCOMMERCE_CONSUMER_SECRET=cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa
```

#### 2.2 Update .gitignore

Make sure to add the `.env` file to `.gitignore` to avoid publishing the keys:

```
# dotenv environment variables file
.env
.env.development
.env.test
.env.production
```

#### 2.3 Create Configuration Service

```dart
// lib/core/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> load() async {
    await dotenv.load();
  }
  
  static String get woocommerceUrl => 
      dotenv.env['WOOCOMMERCE_URL'] ?? 'https://shop.3mcode-solutions.com';
      
  static String get woocommerceConsumerKey => 
      dotenv.env['WOOCOMMERCE_CONSUMER_KEY'] ?? '';
      
  static String get woocommerceConsumerSecret => 
      dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'] ?? '';
}
```

### 3. Update main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_3mcode_shop/app.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load configuration file
  await AppConfig.load();
  
  // Set up Hive for local storage
  await Hive.initFlutter();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}
```

### 4. Create WooCommerce API Service

```dart
// lib/data/services/woocommerce_service.dart
import 'package:woocommerce/woocommerce.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';

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
      baseUrl: AppConfig.woocommerceUrl,
      consumerKey: AppConfig.woocommerceConsumerKey,
      consumerSecret: AppConfig.woocommerceConsumerSecret,
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
  
  // More methods...
}
```

### 5. Update Data Models

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
    // Implementation...
    return '0';
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

### 6. Update Repositories

```dart
// lib/data/repositories/product_repository.dart
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';
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
  
  // More methods...
}
```

## Testing the Integration

### 1. Testing API Connection

```dart
// test/woocommerce_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';

void main() {
  late WooCommerceService wooCommerceService;

  setUp(() {
    wooCommerceService = WooCommerceService();
  });

  test('should get products from WooCommerce API', () async {
    // Act
    final products = await wooCommerceService.getProducts();

    // Assert
    expect(products, isNotEmpty);
    expect(products.first.name, isNotNull);
  });

  test('should get categories from WooCommerce API', () async {
    // Act
    final categories = await wooCommerceService.getCategories();

    // Assert
    expect(categories, isNotEmpty);
    expect(categories.first.name, isNotNull);
  });
}
```

## Conclusion

By following these steps, you can successfully implement the integration of the 3MCode Shop application with the WooCommerce store. Make sure to test each step before moving on to the next one, and verify that the data appears correctly in the application.

---

<p align="center">
  Developed by <a href="https://www.3mcode.com">3MCode</a> - All rights reserved © 2025
</p>
