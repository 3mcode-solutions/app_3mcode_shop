import 'package:flutter/material.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/models/order_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';
import 'package:app_3mcode_shop/presentation/screens/main_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderConfirmationScreen({Key? key, required this.order})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Order Confirmation', showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 60,
              ),
            ),

            const SizedBox(height: 24),

            // Thank You Message
            const Text(
              'Thank You!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Your order #${order.id.substring(4, 10)} has been placed successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // Order Details
            _buildSectionTitle('Order Details'),
            _buildOrderDetailsCard(),

            const SizedBox(height: 24),

            // Shipping Address
            _buildSectionTitle('Shipping Address'),
            _buildAddressCard(),

            const SizedBox(height: 24),

            // Payment Method
            _buildSectionTitle('Payment Method'),
            _buildPaymentMethodCard(),

            const SizedBox(height: 32),

            // Continue Shopping Button
            AnimatedButton(
              text: 'Continue Shopping',
              icon: Icons.shopping_cart,
              onPressed: () {
                AnimatedToast.show(
                  context: context,
                  message: 'Thank you for your order!',
                  type: ToastType.success,
                  onDismiss: () => _continueShopping(context),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow('Order Number', '#${order.id.substring(4, 10)}'),
            const Divider(),
            _buildDetailRow('Date', order.formattedDate),
            const Divider(),
            _buildDetailRow('Time', order.formattedTime),
            const Divider(),
            _buildDetailRow('Total Items', order.totalItems.toString()),
            const Divider(),
            _buildDetailRow('Status', order.statusText),
            const Divider(),
            _buildDetailRow(
              'Total Amount',
              '\$${order.total.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.shippingAddress.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              order.shippingAddress.phoneNumber,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              order.shippingAddress.formattedAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              order.paymentMethod.type == PaymentType.cashOnDelivery
                  ? Icons.money
                  : Icons.credit_card,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.paymentMethod.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.paymentMethod.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _continueShopping(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }
}
