import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/order_model.dart';
import 'package:app_3mcode_shop/data/models/address_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';
import 'package:app_3mcode_shop/presentation/screens/orders/order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Mock orders data - in a real app, this would come from a repository
    final List<OrderModel> orders = _getMockOrders();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('my_orders')),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          orders.isEmpty
              ? _buildEmptyState(context, localizations)
              : _buildOrdersList(context, orders, localizations),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('no_orders_yet'),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('start_shopping_to_see_orders'),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(localizations.translate('start_shopping')),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<OrderModel> orders,
    AppLocalizations localizations,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(order: order),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${localizations.translate('order_id')}: ${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildOrderStatusChip(order.status, localizations),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${localizations.translate('order_date')}: ${_formatDate(order.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.translate('items')}: ${order.items.length}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.translate('total')}: \$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderDetailsScreen(order: order),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(localizations.translate('view_details')),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusChip(
    OrderStatus status,
    AppLocalizations localizations,
  ) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = localizations.translate('pending');
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        text = localizations.translate('processing');
        break;
      case OrderStatus.shipped:
        color = Colors.purple;
        text = localizations.translate('shipped');
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = localizations.translate('delivered');
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = localizations.translate('cancelled');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<OrderModel> _getMockOrders() {
    // This is mock data for demonstration purposes
    // In a real app, this would come from a repository

    // Create mock address and payment method
    final mockAddress = AddressModel(
      fullName: 'John Doe',
      phoneNumber: '+1 (555) 123-4567',
      addressLine1: '123 Main St',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      isDefault: true,
    );

    final mockPaymentMethod = PaymentMethodModel(
      id: '1',
      title: 'Credit Card',
      description: 'Visa ending in 1234',
      type: PaymentType.creditCard,
      cardNumber: '4111111111111234',
      cardHolderName: 'John Doe',
      expiryDate: '12/25',
      isDefault: true,
      iconPath: 'assets/icons/credit_card.png',
    );

    return [
      OrderModel(
        id: 'ORD-1234567',
        items: [],
        shippingAddress: mockAddress,
        paymentMethod: mockPaymentMethod,
        subtotal: 120.0,
        shippingFee: 5.99,
        tax: 6.0,
        total: 131.99,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      OrderModel(
        id: 'ORD-7654321',
        items: [],
        shippingAddress: mockAddress,
        paymentMethod: mockPaymentMethod,
        subtotal: 85.5,
        shippingFee: 5.99,
        tax: 4.28,
        total: 95.77,
        status: OrderStatus.shipped,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderModel(
        id: 'ORD-9876543',
        items: [],
        shippingAddress: mockAddress,
        paymentMethod: mockPaymentMethod,
        subtotal: 210.0,
        shippingFee: 0.0, // Free shipping
        tax: 10.5,
        total: 220.5,
        status: OrderStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
