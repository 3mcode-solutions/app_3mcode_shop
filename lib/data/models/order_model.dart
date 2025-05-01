import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/address_model.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';

/// Enum representing different order statuses
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

/// A model class representing an order
class OrderModel extends Equatable {
  final String id;
  final List<CartItemModel> items;
  final AddressModel shippingAddress;
  final PaymentMethodModel paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       assert(id.isNotEmpty, 'Order ID cannot be empty'),
       assert(items.isNotEmpty, 'Order must have at least one item'),
       assert(subtotal >= 0, 'Subtotal cannot be negative'),
       assert(shippingFee >= 0, 'Shipping fee cannot be negative'),
       assert(tax >= 0, 'Tax cannot be negative'),
       assert(total >= 0, 'Total cannot be negative');

  @override
  List<Object?> get props => [
    id, 
    items, 
    shippingAddress, 
    paymentMethod, 
    subtotal, 
    shippingFee, 
    tax, 
    total,
    status,
    createdAt,
    updatedAt,
  ];
  
  // Create a copy of this OrderModel with the given fields replaced
  OrderModel copyWith({
    String? id,
    List<CartItemModel>? items,
    AddressModel? shippingAddress,
    PaymentMethodModel? paymentMethod,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Get formatted date
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
  
  // Get formatted time
  String get formattedTime {
    return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
  
  // Get status text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
  
  // Get total number of items
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
