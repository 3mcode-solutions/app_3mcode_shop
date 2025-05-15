# تكامل تطبيق 3MCode Shop مع متجر WooCommerce

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

## نظرة عامة

يوثق هذا المستند كيفية ربط تطبيق 3MCode Shop الحالي مع متجر WooCommerce الموجود على الرابط [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/). الهدف هو استخدام التطبيق كواجهة لعرض المنتجات والتفاصيل والسلة والكوبونات وجميع الميزات الموجودة في المتجر الإلكتروني.

## تحليل المتجر الإلكتروني

### المتجر الحالي
- **النظام الأساسي**: WordPress مع WooCommerce
- **الرابط**: [https://shop.3mcode-solutions.com/](https://shop.3mcode-solutions.com/)
- **المنتجات**: دراجات كهربائية مقسمة إلى فئات (City Bikes, Mountain Bikes, Road Bikes)
- **الميزات**:
  - عرض المنتجات
  - تصفية حسب السعر واللون والفئة
  - سلة التسوق
  - المفضلة
  - المقارنة بين المنتجات
  - خيارات المنتج (الألوان)
  - المنتجات ذات الصلة
  - التقييمات والمراجعات

## متطلبات التكامل

1. **واجهة برمجة التطبيقات (API)**: استخدام WooCommerce REST API للوصول إلى بيانات المتجر
2. **المصادقة**: إعداد مفاتيح API للوصول الآمن إلى البيانات
3. **مزامنة البيانات**: تحديث بيانات التطبيق مع المتجر الإلكتروني
4. **تخزين محلي**: تخزين البيانات محلياً للاستخدام في وضع عدم الاتصال
5. **تسجيل الدخول**: دعم تسجيل الدخول باستخدام حسابات المتجر الإلكتروني

## الحل التقني

### 1. إعداد WooCommerce REST API

#### 1.1 إنشاء مفاتيح API

1. تسجيل الدخول إلى لوحة تحكم WordPress
2. الانتقال إلى WooCommerce > الإعدادات > متقدم > REST API
3. إنشاء مفتاح جديد مع الأذونات المناسبة:
   - `read` - للوصول للقراءة فقط
   - `write` - للوصول للقراءة والكتابة
   - `read_write` - للوصول الكامل

```
مستوى الأذونات المطلوب: read_write
```

#### 1.2 تخزين مفاتيح API بشكل آمن

يجب تخزين مفاتيح API بشكل آمن وعدم تضمينها مباشرة في كود التطبيق:

```dart
// استخدام ملف تكوين آمن أو خدمة تخزين آمنة
// لا تقم بتضمين هذه المفاتيح مباشرة في كود التطبيق
// استخدم ملف .env أو Flutter Secure Storage
final Map<String, String> apiKeys = {
  'consumerKey': 'ck_d8685bb37c4b813b68ce3077dc71e43375bc95aa',
  'consumerSecret': 'cs_6583c4b8b4055f013ec7080290cb4ea3d676faaa',
};
```

### 2. إضافة مكتبات التكامل مع WooCommerce

#### 2.1 تحديث ملف pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  # المكتبات الحالية...

  # مكتبات WooCommerce
  woocommerce: ^0.9.7
  # أو
  woocommerce_api: ^0.1.0

  # مكتبات إضافية
  dio: ^5.4.0
  cached_network_image: ^3.3.1
  connectivity_plus: ^5.0.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

#### 2.2 إنشاء خدمة WooCommerce API

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

  // إضافة منتج إلى سلة التسوق
  Future<bool> addToCart(int productId, int quantity) async {
    return await _wooCommerce.addToCart(
      productId: productId,
      quantity: quantity,
    );
  }

  // الحصول على محتويات سلة التسوق
  Future<List<WooCartItem>> getCart() async {
    return await _wooCommerce.getCart();
  }

  // تحديث كمية منتج في سلة التسوق
  Future<bool> updateCartItemQuantity(
    String key,
    int quantity,
  ) async {
    return await _wooCommerce.updateCartItemQuantity(
      key: key,
      quantity: quantity,
    );
  }

  // إزالة منتج من سلة التسوق
  Future<bool> removeCartItem(String key) async {
    return await _wooCommerce.removeCartItem(key: key);
  }

  // تسجيل الدخول
  Future<WooCustomer?> login(String username, String password) async {
    return await _wooCommerce.loginCustomer(
      username: username,
      password: password,
    );
  }

  // إنشاء حساب جديد
  Future<WooCustomer> createCustomer(WooCustomerCreate customer) async {
    return await _wooCommerce.createCustomer(customer);
  }

  // الحصول على الكوبونات
  Future<List<WooCoupon>> getCoupons() async {
    return await _wooCommerce.getCoupons();
  }

  // تطبيق كوبون
  Future<bool> applyCoupon(String code) async {
    return await _wooCommerce.applyCoupon(code: code);
  }

  // إنشاء طلب
  Future<WooOrder> createOrder(WooOrderPayload orderPayload) async {
    return await _wooCommerce.createOrder(orderPayload);
  }
}
```

### 3. تعديل نماذج البيانات

#### 3.1 تحويل نموذج المنتج

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

### 4. تعديل المستودعات

#### 4.1 تحديث مستودع المنتجات

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

  /// البحث عن المنتجات
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
      // البحث في البيانات المخزنة محلياً
      final products = await _getLocalProducts();
      final lowercaseQuery = query.toLowerCase();

      return products
          .where((product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    }
  }

  /// الحصول على المنتجات حسب الفئة
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    try {
      final wooProducts = await _wooCommerceService.getProducts(
        category: categoryName,
      );

      return wooProducts
          .map((product) => ProductModel.fromWooProduct(product))
          .toList();
    } catch (e) {
      // البحث في البيانات المخزنة محلياً
      final products = await _getLocalProducts();

      return products
          .where((product) =>
              product.category.toLowerCase() == categoryName.toLowerCase())
          .toList();
    }
  }

  /// تخزين المنتجات محلياً
  Future<void> _saveProductsLocally(List<ProductModel> products) async {
    final box = await Hive.openBox<Map>(_productsBoxName);

    // تحويل المنتجات إلى خرائط
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

    // حفظ البيانات
    await box.clear();
    for (var productMap in productMaps) {
      await box.add(productMap);
    }
  }

  /// استرجاع المنتجات المخزنة محلياً
  Future<List<ProductModel>> _getLocalProducts() async {
    final box = await Hive.openBox<Map>(_productsBoxName);

    if (box.isEmpty) {
      return [];
    }

    // تحويل الخرائط إلى نماذج
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

## خطوات التنفيذ

### 1. إعداد البيئة

1. تحديث ملف `pubspec.yaml` بالمكتبات المطلوبة
2. تثبيت المكتبات: `flutter pub get`
3. إعداد Hive للتخزين المحلي:
   ```dart
   // في main.dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Hive.initFlutter();
     runApp(const App());
   }
   ```

### 2. تنفيذ الخدمات والمستودعات

1. إنشاء خدمة WooCommerce API
2. تحديث نماذج البيانات
3. تعديل المستودعات لاستخدام API

### 3. تحديث واجهة المستخدم

1. تعديل شاشات عرض المنتجات
2. تحديث شاشة تفاصيل المنتج لعرض الخيارات والصور المتعددة
3. تعديل سلة التسوق للتكامل مع WooCommerce

### 4. اختبار التكامل

1. اختبار الاتصال بـ API
2. اختبار عرض المنتجات والفئات
3. اختبار سلة التسوق والطلبات
4. اختبار وضع عدم الاتصال

## الخلاصة

يمكن تكامل تطبيق 3MCode Shop مع متجر WooCommerce بسهولة باستخدام WooCommerce REST API. هذا التكامل سيسمح للتطبيق بعرض جميع المنتجات والتفاصيل والميزات الموجودة في المتجر الإلكتروني، مع الحفاظ على تجربة مستخدم سلسة وأداء جيد.

---

<p align="center">
  تم التطوير بواسطة <a href="https://www.3mcode.com">3MCode</a> - جميع الحقوق محفوظة © 2025
</p>
