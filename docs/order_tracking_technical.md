# التوثيق التقني لميزة تتبع الطلب

## المكتبات المستخدمة

```yaml
dependencies:
  flutter_map: ^5.0.0  # مكتبة لعرض خرائط OpenStreetMap
  latlong2: ^0.9.0     # مكتبة للتعامل مع الإحداثيات الجغرافية
  http: ^1.3.0         # مكتبة للتعامل مع طلبات HTTP
```

## نموذج البيانات

### OrderTrackingModel

```dart
/// حالات الطلب المختلفة
enum OrderStatus {
  processing,  // قيد التجهيز
  packed,      // تم التغليف
  shipped,     // تم الشحن
  inTransit,   // قيد التوصيل
  delivered,   // تم التسليم
}

/// نموذج بيانات لتتبع الطلب
class OrderTrackingModel extends Equatable {
  final String orderId;
  final OrderStatus status;
  final DateTime estimatedDelivery;
  final LatLng storeLocation;
  final LatLng customerLocation;
  final LatLng? currentLocation;
  final String? courierName;
  final String? courierPhone;
  
  const OrderTrackingModel({
    required this.orderId,
    required this.status,
    required this.estimatedDelivery,
    required this.storeLocation,
    required this.customerLocation,
    this.currentLocation,
    this.courierName,
    this.courierPhone,
  });
  
  // ... باقي الكود
}
```

## شاشة تتبع الطلب

### OrderTrackingScreenOSM

```dart
class OrderTrackingScreenOSM extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingScreenOSM({
    Key? key,
    required this.orderId,
  }) : super(key: key);
  
  @override
  State<OrderTrackingScreenOSM> createState() => _OrderTrackingScreenOSMState();
}

class _OrderTrackingScreenOSMState extends State<OrderTrackingScreenOSM> {
  OrderTrackingModel? _trackingData;
  bool _isLoading = true;
  final MapController _mapController = MapController();
  
  @override
  void initState() {
    super.initState();
    _loadTrackingData();
  }
  
  Future<void> _loadTrackingData() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(seconds: 2));
    
    // في التطبيق الحقيقي، ستقوم بجلب البيانات من API
    setState(() {
      _trackingData = OrderTrackingModel.getMockData(widget.orderId);
      _isLoading = false;
    });
  }
  
  // ... باقي الكود
}
```

## الدوال الرئيسية

### 1. بناء الخريطة

```dart
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    center: LatLng(
      _trackingData!.storeLocation.latitude,
      _trackingData!.storeLocation.longitude,
    ),
    zoom: 13.0,
    onMapReady: () {
      _fitBounds();
    },
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app_3mcode_shop',
    ),
    PolylineLayer(
      polylines: _buildPolylines(),
    ),
    MarkerLayer(
      markers: _buildMarkers(),
    ),
  ],
)
```

### 2. بناء العلامات (Markers)

```dart
List<Marker> _buildMarkers() {
  List<Marker> markers = [];
  
  // إضافة علامة للمتجر
  markers.add(
    Marker(
      point: LatLng(
        _trackingData!.storeLocation.latitude,
        _trackingData!.storeLocation.longitude,
      ),
      width: 80,
      height: 80,
      builder: (context) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 30),
          ),
          const Text('المتجر', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
  
  // ... إضافة علامات للعميل والساعي
  
  return markers;
}
```

### 3. بناء المسارات (Polylines)

```dart
List<Polyline> _buildPolylines() {
  List<Polyline> polylines = [];
  
  if (_trackingData!.currentLocation != null) {
    // رسم المسار من المتجر إلى الساعي
    polylines.add(
      Polyline(
        points: [
          LatLng(
            _trackingData!.storeLocation.latitude,
            _trackingData!.storeLocation.longitude,
          ),
          LatLng(
            _trackingData!.currentLocation!.latitude,
            _trackingData!.currentLocation!.longitude,
          ),
        ],
        strokeWidth: 4.0,
        color: Colors.blue,
      ),
    );
    
    // رسم المسار من الساعي إلى العميل (خط متقطع)
    polylines.add(
      Polyline(
        points: [
          LatLng(
            _trackingData!.currentLocation!.latitude,
            _trackingData!.currentLocation!.longitude,
          ),
          LatLng(
            _trackingData!.customerLocation.latitude,
            _trackingData!.customerLocation.longitude,
          ),
        ],
        strokeWidth: 4.0,
        color: Colors.blue.withAlpha(128),
        isDotted: true,
      ),
    );
  } else {
    // رسم مسار مباشر من المتجر إلى العميل
    // ... الكود
  }
  
  return polylines;
}
```

### 4. ضبط حدود الخريطة

```dart
void _fitBounds() {
  // جمع جميع النقاط التي نريد إظهارها في الخريطة
  List<LatLng> points = [
    LatLng(
      _trackingData!.storeLocation.latitude,
      _trackingData!.storeLocation.longitude,
    ),
    LatLng(
      _trackingData!.customerLocation.latitude,
      _trackingData!.customerLocation.longitude,
    ),
  ];
  
  if (_trackingData!.currentLocation != null) {
    points.add(
      LatLng(
        _trackingData!.currentLocation!.latitude,
        _trackingData!.currentLocation!.longitude,
      ),
    );
  }
  
  // حساب الحدود
  double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
  double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
  double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
  double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
  
  // إضافة هامش
  double padding = 0.01;
  
  // تحريك الكاميرا لتشمل جميع النقاط
  _mapController.fitBounds(
    LatLngBounds(
      LatLng(minLat - padding, minLng - padding),
      LatLng(maxLat + padding, maxLng + padding),
    ),
    options: const FitBoundsOptions(padding: EdgeInsets.all(50)),
  );
}
```

## التكامل مع التطبيق

### 1. إضافة زر تتبع الطلب في شاشة تفاصيل الطلب

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreenOSM(
          orderId: order.id,
        ),
      ),
    );
  },
  child: Text(localizations.translate('track_order')),
)
```

### 2. إضافة الترجمات

```json
// ar.json
{
  "track_order": "تتبع الطلب",
  "estimated_delivery": "موعد التسليم المتوقع",
  "courier": "الساعي",
  "calling_courier": "جاري الاتصال بالساعي...",
  "processing": "قيد التجهيز",
  "packed": "تم التغليف",
  "shipped": "تم الشحن",
  "in_transit": "قيد التوصيل",
  "delivered": "تم التسليم"
}

// en.json
{
  "track_order": "Track Order",
  "estimated_delivery": "Estimated Delivery",
  "courier": "Courier",
  "calling_courier": "Calling courier...",
  "processing": "Processing",
  "packed": "Packed",
  "shipped": "Shipped",
  "in_transit": "In Transit",
  "delivered": "Delivered"
}
```

## ملاحظات تقنية

1. **استخدام OpenStreetMap**: تم اختيار OpenStreetMap لأنه مجاني تمامًا بدون قيود على الاستخدام
2. **تحسين الأداء**: تم استخدام `MapController` للتحكم في الخريطة وضبط حدودها
3. **التوافق**: تم التأكد من توافق جميع المكتبات مع بعضها البعض
4. **الترجمة**: تم دعم اللغتين العربية والإنجليزية بشكل كامل

## الأمان

1. **بيانات المستخدم**: لا يتم تخزين أي بيانات حساسة على الجهاز
2. **الخصوصية**: يتم استخدام OpenStreetMap الذي يحترم خصوصية المستخدم
3. **الاتصال**: يتم استخدام HTTPS للاتصال بخوادم OpenStreetMap

## الاختبار

تم اختبار الميزة على:
- أجهزة Android مختلفة
- إصدارات مختلفة من نظام التشغيل
- أحجام شاشات مختلفة
- اتصالات إنترنت مختلفة السرعة
