# خطوات تنفيذ تكامل تطبيق 3MCode Shop مع متجر WooCommerce

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

## مقدمة

هذا المستند يوضح الخطوات العملية لتنفيذ تكامل تطبيق 3MCode Shop مع متجر WooCommerce الموجود على الرابط [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/). تم إنشاء مفاتيح API اللازمة وهي جاهزة للاستخدام.

## المتطلبات المسبقة

1. تثبيت Flutter SDK وإعداد بيئة التطوير
2. الوصول إلى مشروع تطبيق 3MCode Shop الحالي
3. الوصول إلى لوحة تحكم WordPress للمتجر الإلكتروني
4. مفاتيح API التي تم إنشاؤها:
   - Consumer Key: `ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa`
   - Consumer Secret: `cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa`

## خطوات التنفيذ

### 1. تحديث ملف pubspec.yaml

أضف المكتبات اللازمة لتكامل WooCommerce:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # المكتبات الحالية...
  
  # مكتبات WooCommerce
  woocommerce: ^0.9.7
  
  # مكتبات إضافية
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  connectivity_plus: ^5.0.2
  flutter_secure_storage: ^9.0.0
  flutter_dotenv: ^5.1.0
```

ثم قم بتثبيت المكتبات:

```bash
flutter pub get
```

### 2. إعداد التخزين الآمن للمفاتيح

#### 2.1 إنشاء ملف .env

قم بإنشاء ملف `.env` في جذر المشروع:

```
WOOCOMMERCE_URL=https://shop.3mcode-solutions.com
WOOCOMMERCE_CONSUMER_KEY=ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa
WOOCOMMERCE_CONSUMER_SECRET=cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa
```

#### 2.2 تحديث ملف .gitignore

تأكد من إضافة ملف `.env` إلى `.gitignore` لتجنب نشر المفاتيح:

```
# dotenv environment variables file
.env
.env.development
.env.test
.env.production
```

#### 2.3 إنشاء خدمة التكوين

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

### 3. تحديث main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_3mcode_shop/app.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل ملف التكوين
  await AppConfig.load();
  
  // إعداد Hive للتخزين المحلي
  await Hive.initFlutter();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}
```

### 4. إنشاء خدمة WooCommerce API

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
  
  // الحصول على المنتجات
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
  
  // الحصول على فئات المنتجات
  Future<List<WooProductCategory>> getCategories() async {
    return await _wooCommerce.getProductCategories();
  }
  
  // الحصول على تفاصيل منتج
  Future<WooProduct> getProduct(int id) async {
    return await _wooCommerce.getProductById(id: id);
  }
  
  // المزيد من الأساليب...
}
```

### 5. تحديث نماذج البيانات

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

  // تحويل من WooProduct إلى ProductModel
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

  // حساب نسبة الخصم
  static String _calculateDiscountPercentage(
    String? regularPrice,
    String? salePrice,
  ) {
    // التنفيذ...
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

### 6. تحديث المستودعات

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
  
  /// الحصول على جميع المنتجات
  Future<List<ProductModel>> getProducts() async {
    try {
      // التحقق من الاتصال بالإنترنت
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool hasInternet = connectivityResult != ConnectivityResult.none;
      
      if (hasInternet) {
        // الحصول على البيانات من API
        final wooProducts = await _wooCommerceService.getProducts(
          perPage: 50,
        );
        
        // تحويل البيانات إلى نموذج التطبيق
        final products = wooProducts
            .map((product) => ProductModel.fromWooProduct(product))
            .toList();
        
        // تخزين البيانات محلياً
        await _saveProductsLocally(products);
        
        return products;
      } else {
        // استرجاع البيانات المخزنة محلياً
        return await _getLocalProducts();
      }
    } catch (e) {
      // في حالة حدوث خطأ، استرجاع البيانات المخزنة محلياً
      return await _getLocalProducts();
    }
  }
  
  // المزيد من الأساليب...
}
```

## اختبار التكامل

### 1. اختبار الاتصال بـ API

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

## الخلاصة

باتباع هذه الخطوات، يمكنك تنفيذ تكامل تطبيق 3MCode Shop مع متجر WooCommerce بنجاح. تأكد من اختبار كل خطوة قبل الانتقال إلى الخطوة التالية، وتحقق من أن البيانات تظهر بشكل صحيح في التطبيق.

---

<p align="center">
  تم التطوير بواسطة <a href="https://www.3mcode.com">3MCode</a> - جميع الحقوق محفوظة © 2025
</p>
