# ميزة وضع عدم الاتصال في تطبيق 3MCode Shop

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#overview">نظرة عامة</a> •
  <a href="#features">الميزات</a> •
  <a href="#implementation">التنفيذ</a> •
  <a href="#user-experience">تجربة المستخدم</a> •
  <a href="#technical-details">التفاصيل التقنية</a> •
  <a href="#future-improvements">التحسينات المستقبلية</a>
</p>

## <a id="overview"></a>نظرة عامة

تتيح ميزة وضع عدم الاتصال للمستخدمين استخدام تطبيق 3MCode Shop حتى عندما لا يكون لديهم اتصال بالإنترنت. يمكن للمستخدمين تصفح المنتجات، وإضافتها إلى سلة التسوق، وحتى إكمال عملية الشراء في وضع عدم الاتصال. عندما يستعيد المستخدم الاتصال بالإنترنت، تتم مزامنة الطلبات المعلقة تلقائيًا مع خادم WooCommerce.

## <a id="features"></a>الميزات

### تصفح المنتجات في وضع عدم الاتصال
- عرض المنتجات المخزنة محليًا
- البحث عن المنتجات وتصفيتها في وضع عدم الاتصال
- عرض تفاصيل المنتج الكاملة

### إدارة سلة التسوق في وضع عدم الاتصال
- إضافة المنتجات إلى سلة التسوق
- تعديل كمية المنتجات في السلة
- إزالة المنتجات من السلة
- حساب المجموع الفرعي والضرائب ورسوم الشحن

### إكمال عملية الشراء في وضع عدم الاتصال
- إدخال معلومات الشحن
- اختيار طريقة الدفع
- إنشاء طلب محلي
- تخزين الطلب محليًا للمزامنة لاحقًا

### مزامنة الطلبات عند استعادة الاتصال
- مزامنة تلقائية للطلبات المعلقة عند استعادة الاتصال بالإنترنت
- إشعار المستخدم بحالة المزامنة
- إدارة الأخطاء والتعافي منها

## <a id="implementation"></a>التنفيذ

تم تنفيذ ميزة وضع عدم الاتصال باستخدام المكونات التالية:

### 1. خدمة التخزين المؤقت (CacheService)
تم إنشاء خدمة جديدة تقوم بتخزين استجابات API مؤقتًا وإدارة انتهاء صلاحية التخزين المؤقت. تستخدم هذه الخدمة `SharedPreferences` لتخزين البيانات محليًا.

### 2. خدمة مزامنة الطلبات (OrderSyncService)
تم إنشاء خدمة جديدة تقوم بمزامنة الطلبات المعلقة عند استعادة الاتصال بالإنترنت. تستخدم هذه الخدمة `Connectivity` للاستماع إلى تغييرات الاتصال و`SharedPreferences` لتخزين الطلبات المعلقة.

### 3. تعديل مستودع المنتجات (ProductRepository)
تم تعديل مستودع المنتجات لاستخدام خدمة التخزين المؤقت وتوفير دعم لوضع عدم الاتصال.

### 4. تعديل شاشة الدفع (PaymentScreen)
تم تعديل شاشة الدفع للتعامل مع وضع عدم الاتصال وإنشاء طلبات محلية عند الحاجة.

## <a id="user-experience"></a>تجربة المستخدم

### إشعارات وضع عدم الاتصال
- يتم إشعار المستخدم عندما يكون التطبيق في وضع عدم الاتصال
- يتم إشعار المستخدم عندما يتم إنشاء طلب في وضع عدم الاتصال
- يتم إشعار المستخدم عندما تتم مزامنة الطلبات المعلقة

### تجربة سلسة
- يمكن للمستخدم الاستمرار في استخدام التطبيق بشكل طبيعي في وضع عدم الاتصال
- لا يوجد تغيير كبير في واجهة المستخدم أو تدفق العمل
- يتم التعامل مع الأخطاء والاستثناءات بشكل مناسب

## <a id="technical-details"></a>التفاصيل التقنية

### خدمة التخزين المؤقت (CacheService)

تم تنفيذ خدمة التخزين المؤقت لتخزين استجابات API مؤقتًا وإدارة انتهاء صلاحية التخزين المؤقت. تستخدم هذه الخدمة `SharedPreferences` لتخزين البيانات محليًا.

```dart
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  // Cache expiration time (in minutes)
  final int _defaultCacheExpirationMinutes = 30;

  /// Get data from cache or API
  Future<dynamic> getOrFetchData({
    required String cacheKey,
    required Future<dynamic> Function() fetchFunction,
    int? cacheExpirationMinutes,
    bool forceRefresh = false,
  }) async {
    // Check internet connection
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivityResult != ConnectivityResult.none;

    // If no internet connection, always try to get from cache
    if (!hasInternet) {
      return await _getFromCache(cacheKey);
    }

    // If force refresh, always fetch from API
    if (forceRefresh) {
      return await _fetchAndCache(cacheKey, fetchFunction, cacheExpirationMinutes);
    }

    // Try to get from cache first
    final cachedData = await _getFromCache(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // If not in cache or expired, fetch from API
    return await _fetchAndCache(cacheKey, fetchFunction, cacheExpirationMinutes);
  }
}
```

### خدمة مزامنة الطلبات (OrderSyncService)

تم تنفيذ خدمة مزامنة الطلبات لمزامنة الطلبات المعلقة عند استعادة الاتصال بالإنترنت. تستخدم هذه الخدمة `Connectivity` للاستماع إلى تغييرات الاتصال و`SharedPreferences` لتخزين الطلبات المعلقة.

```dart
class OrderSyncService {
  // Singleton pattern
  static final OrderSyncService _instance = OrderSyncService._internal();

  factory OrderSyncService() {
    return _instance;
  }

  // Private constructor
  OrderSyncService._internal() {
    // Initialize connectivity subscription
    _initConnectivitySubscription();
  }

  // Connectivity subscription
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Initialize connectivity subscription
  void _initConnectivitySubscription() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Internet connection restored, sync pending orders
        _syncPendingOrders();
      }
    });
  }
}
```

## <a id="future-improvements"></a>التحسينات المستقبلية

### تحسين تجربة المستخدم
- إضافة مؤشر حالة الاتصال في واجهة المستخدم
- إضافة شاشة لعرض الطلبات المعلقة
- إضافة خيار لمزامنة الطلبات يدويًا

### تحسين الأداء
- تحسين استخدام الذاكرة وتخزين البيانات
- تحسين أداء المزامنة
- تحسين إدارة الأخطاء والتعافي منها

### ميزات إضافية
- دعم مزامنة المفضلة
- دعم مزامنة الإعدادات
- دعم مزامنة معلومات المستخدم
