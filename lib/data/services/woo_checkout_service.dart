import 'package:app_3mcode_shop/data/models/address_model.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';

/// Service for handling WooCommerce checkout process
class WooCheckoutService {
  final WooCommerceService _wooCommerceService = WooCommerceService();

  /// Create a WooCommerce order from cart items and shipping information
  Future<Map<String, dynamic>> createOrder({
    required List<CartItemModel> items,
    required AddressModel shippingAddress,
    required PaymentMethodModel paymentMethod,
    required double subtotal,
    required double shippingFee,
    required double tax,
    required double total,
  }) async {
    try {
      // Convert cart items to WooCommerce line items format
      final lineItems = items.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'name': item.product.name,
            'price': item.product.price,
            'total': (item.product.price * item.quantity).toString(),
          }).toList();

      // Create shipping address in WooCommerce format
      final shipping = {
        'first_name': shippingAddress.fullName.split(' ').first,
        'last_name': shippingAddress.fullName.split(' ').length > 1
            ? shippingAddress.fullName.split(' ').skip(1).join(' ')
            : '',
        'address_1': shippingAddress.addressLine1,
        'address_2': shippingAddress.addressLine2,
        'city': shippingAddress.city,
        'state': shippingAddress.state,
        'postcode': shippingAddress.zipCode,
        'country': 'EG', // Default to Egypt, can be made dynamic
      };

      // Create billing address (same as shipping for now)
      final billing = {
        ...shipping,
        'email': 'customer@example.com', // This should come from user profile
        'phone': shippingAddress.phoneNumber,
      };

      // Create order data
      final orderData = {
        'payment_method': paymentMethod.type == PaymentType.cashOnDelivery
            ? 'cod'
            : 'bacs', // bacs = direct bank transfer
        'payment_method_title': paymentMethod.title,
        'set_paid': paymentMethod.type != PaymentType.cashOnDelivery,
        'billing': billing,
        'shipping': shipping,
        'line_items': lineItems,
        'shipping_lines': [
          {
            'method_id': 'flat_rate',
            'method_title': 'Flat Rate',
            'total': shippingFee.toString(),
          }
        ],
        'fee_lines': [
          {
            'name': 'Tax',
            'total': tax.toString(),
            'tax_class': '',
            'tax_status': 'taxable',
          }
        ],
      };

      // Send order to WooCommerce API
      final response = await _wooCommerceService.createOrder(orderData);
      
      print('✅ Order created successfully: ${response['id']}');
      return response;
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  /// Process payment for an order
  /// This is a mock implementation as actual payment processing depends on the payment gateway
  Future<bool> processPayment({
    required String orderId,
    required PaymentMethodModel paymentMethod,
    required double amount,
  }) async {
    try {
      // For cash on delivery, no payment processing is needed
      if (paymentMethod.type == PaymentType.cashOnDelivery) {
        return true;
      }

      // For credit card or other payment methods, we would integrate with a payment gateway
      // This is a mock implementation
      await Future.delayed(const Duration(seconds: 2));
      
      // Update order status to processing
      await _wooCommerceService.put('orders/$orderId', {
        'status': 'processing',
      });
      
      return true;
    } catch (e) {
      print('❌ Error processing payment: $e');
      return false;
    }
  }
}
