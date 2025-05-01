import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// حالات الطلب المختلفة
enum OrderStatus {
  processing, // قيد التجهيز
  packed, // تم التغليف
  shipped, // تم الشحن
  inTransit, // قيد التوصيل
  delivered, // تم التسليم
}

/// نموذج بيانات لتتبع الطلب
class OrderTrackingModel extends Equatable {
  final String orderId;
  final OrderStatus status;
  final DateTime estimatedDelivery;
  final LatLng storeLocation;
  final LatLng customerLocation;
  final LatLng? currentLocation; // موقع الساعي (إذا كان متاح)
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

  @override
  List<Object?> get props => [
    orderId,
    status,
    estimatedDelivery,
    storeLocation,
    customerLocation,
    currentLocation,
    courierName,
    courierPhone,
  ];

  /// الحصول على نص حالة الطلب
  String getStatusText() {
    switch (status) {
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.packed:
        return 'تم التغليف';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.inTransit:
        return 'قيد التوصيل';
      case OrderStatus.delivered:
        return 'تم التسليم';
    }
  }

  /// تنسيق التاريخ والوقت
  String formatDateTime() {
    return '${estimatedDelivery.day}/${estimatedDelivery.month}/${estimatedDelivery.year} ${estimatedDelivery.hour}:${estimatedDelivery.minute.toString().padLeft(2, '0')}';
  }

  /// إنشاء نسخة جديدة من النموذج مع تحديث بعض الخصائص
  OrderTrackingModel copyWith({
    String? orderId,
    OrderStatus? status,
    DateTime? estimatedDelivery,
    LatLng? storeLocation,
    LatLng? customerLocation,
    LatLng? currentLocation,
    String? courierName,
    String? courierPhone,
  }) {
    return OrderTrackingModel(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      storeLocation: storeLocation ?? this.storeLocation,
      customerLocation: customerLocation ?? this.customerLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
    );
  }

  /// إنشاء نموذج وهمي للاختبار
  static OrderTrackingModel getMockData(String orderId) {
    return OrderTrackingModel(
      orderId: orderId,
      status: OrderStatus.inTransit,
      estimatedDelivery: DateTime.now().add(const Duration(hours: 2)),
      storeLocation: const LatLng(30.0444, 31.2357), // القاهرة
      customerLocation: const LatLng(30.0626, 31.2497), // موقع قريب
      currentLocation: const LatLng(30.0530, 31.2420), // موقع الساعي
      courierName: 'أحمد محمد',
      courierPhone: '+20 123 456 7890',
    );
  }
}
