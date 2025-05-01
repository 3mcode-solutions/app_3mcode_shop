import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/localization/app_localizations.dart';
import 'package:app_3mcode_shop/data/models/order_model.dart';
import 'package:app_3mcode_shop/presentation/screens/orders/order_tracking_screen_osm.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('order_details')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfo(context, localizations),
            const SizedBox(height: 24),
            _buildOrderItems(context, localizations),
            const SizedBox(height: 24),
            _buildOrderSummary(context, localizations),
            const SizedBox(height: 24),
            _buildShippingInfo(context, localizations),
            const SizedBox(height: 24),
            _buildPaymentInfo(context, localizations),
            const SizedBox(height: 32),
            _buildActionButtons(context, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, AppLocalizations localizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('order_information'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(localizations.translate('order_id'), order.id),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('order_date'),
              _formatDate(order.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('order_status'),
              _getStatusText(order.status, localizations),
              valueColor: _getStatusColor(order.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('order_items'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // In a real app, we would display the actual items here
            // For now, we'll just show a placeholder
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              title: const Text('Product 1'),
              subtitle: const Text('Quantity: 2'),
              trailing: const Text('\$45.99'),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              title: const Text('Product 2'),
              subtitle: const Text('Quantity: 1'),
              trailing: const Text('\$29.99'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('order_summary'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              localizations.translate('subtotal'),
              '\$${order.subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('shipping'),
              order.shippingFee > 0
                  ? '\$${order.shippingFee.toStringAsFixed(2)}'
                  : localizations.translate('free'),
              valueColor: order.shippingFee > 0 ? null : Colors.green,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('tax'),
              '\$${order.tax.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              localizations.translate('total'),
              '\$${order.total.toStringAsFixed(2)}',
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('shipping_information'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // In a real app, we would display the actual shipping address
            // For now, we'll just show a placeholder
            _buildInfoRow(localizations.translate('name'), 'John Doe'),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('address'),
              '123 Main St, Apt 4B',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('city_state_zip'),
              'New York, NY 10001',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('phone'),
              '+1 (555) 123-4567',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.translate('payment_information'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // In a real app, we would display the actual payment method
            // For now, we'll just show a placeholder
            _buildInfoRow(
              localizations.translate('payment_method'),
              'Credit Card',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('card_number'),
              '**** **** **** 1234',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              localizations.translate('payment_status'),
              localizations.translate('paid'),
              valueColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to order tracking screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => OrderTrackingScreenOSM(orderId: order.id),
                ),
              );
            },
            icon: const Icon(Icons.local_shipping),
            label: Text(localizations.translate('track_order')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // In a real app, this would contact support
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    localizations.translate('support_contact_initiated'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.support_agent),
            label: Text(localizations.translate('contact_support')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(fontWeight: FontWeight.w500, color: valueColor),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusText(OrderStatus status, AppLocalizations localizations) {
    switch (status) {
      case OrderStatus.pending:
        return localizations.translate('pending');
      case OrderStatus.processing:
        return localizations.translate('processing');
      case OrderStatus.shipped:
        return localizations.translate('shipped');
      case OrderStatus.delivered:
        return localizations.translate('delivered');
      case OrderStatus.cancelled:
        return localizations.translate('cancelled');
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
