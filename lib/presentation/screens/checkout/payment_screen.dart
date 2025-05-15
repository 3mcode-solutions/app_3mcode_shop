import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/data/models/address_model.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';
import 'package:app_3mcode_shop/data/models/order_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';
import 'package:app_3mcode_shop/data/services/order_sync_service.dart';
import 'package:app_3mcode_shop/data/services/woo_checkout_service.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_event.dart';
import 'package:app_3mcode_shop/presentation/screens/checkout/order_confirmation_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PaymentScreen extends StatefulWidget {
  final AddressModel address;
  final PaymentMethodModel paymentMethod;
  final double total;

  const PaymentScreen({
    Key? key,
    required this.address,
    required this.paymentMethod,
    required this.total,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  int _progressValue = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_isProcessing) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Payment', showBackButton: true),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Info
                  _buildSectionTitle('Payment Method'),
                  _buildPaymentMethodCard(),

                  const SizedBox(height: 24),

                  // Shipping Address
                  _buildSectionTitle('Shipping Address'),
                  _buildAddressCard(),

                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionTitle('Order Summary'),
                  _buildOrderSummary(state),

                  const SizedBox(height: 24),

                  // Payment Progress
                  if (_isProcessing) _buildPaymentProgress(),

                  const SizedBox(height: 24),

                  // Pay Now Button
                  if (!_isProcessing)
                    AnimatedButton(
                      text:
                          widget.paymentMethod.type ==
                                  PaymentType.cashOnDelivery
                              ? 'Place Order'
                              : 'Pay Now',
                      icon:
                          widget.paymentMethod.type ==
                                  PaymentType.cashOnDelivery
                              ? Icons.local_shipping
                              : Icons.payment,
                      onPressed: () {
                        AnimatedToast.show(
                          context: context,
                          message:
                              widget.paymentMethod.type ==
                                      PaymentType.cashOnDelivery
                                  ? 'Processing your order...'
                                  : 'Processing payment...',
                          type: ToastType.info,
                        );

                        _processPayment();
                      },
                    ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              widget.paymentMethod.type == PaymentType.cashOnDelivery
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
                    widget.paymentMethod.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.paymentMethod.description,
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

  Widget _buildAddressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.address.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.address.phoneNumber,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              widget.address.formattedAddress,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded state) {
    final cartItems = state.items;
    final subtotal = cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalDiscountedPrice,
    );
    final shippingFee = 5.99;
    final tax = subtotal * 0.05; // 5% tax

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
              'Items (${cartItems.length})',
              '\$${subtotal.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildSummaryRow('Shipping', '\$${shippingFee.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow('Tax (5%)', '\$${tax.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total',
              '\$${widget.total.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
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

  Widget _buildPaymentProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progressValue / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 16),
        Text(
          _progressValue < 100
              ? 'Processing payment...'
              : 'Payment successful!',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _processPayment() {
    setState(() {
      _isProcessing = true;
      _progressValue = 0;
    });

    // Simulate payment processing
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progressValue < 100) {
          _progressValue += 2;
        } else {
          _timer.cancel();
          _completeOrder();
        }
      });
    });
  }

  void _completeOrder() async {
    if (!mounted) return;

    try {
      final cartState = context.read<CartBloc>().state;
      if (cartState is CartLoaded) {
        final subtotal = cartState.items.fold(
          0.0,
          (sum, item) => sum + item.totalDiscountedPrice,
        );
        final shippingFee = 5.99;
        final tax = subtotal * 0.05;
        final cartItems = List<CartItemModel>.from(
          cartState.items,
        ); // Create a copy of cart items
        final cartBloc = context.read<CartBloc>(); // Get bloc reference

        // Check internet connection
        final connectivityResult = await Connectivity().checkConnectivity();
        final bool hasInternet = connectivityResult != ConnectivityResult.none;

        // Create services
        final wooCheckoutService = WooCheckoutService();
        final orderSyncService = OrderSyncService();

        if (hasInternet) {
          try {
            // Show processing message
            if (!mounted) return;
            AnimatedToast.show(
              context: context,
              message: 'Creating your order...',
              type: ToastType.info,
            );

            // Create order in WooCommerce
            final wooOrder = await wooCheckoutService.createOrder(
              items: cartItems,
              shippingAddress: widget.address,
              paymentMethod: widget.paymentMethod,
              subtotal: subtotal,
              shippingFee: shippingFee,
              tax: tax,
              total: widget.total,
            );

            // Process payment
            final paymentSuccess = await wooCheckoutService.processPayment(
              orderId: wooOrder['id'].toString(),
              paymentMethod: widget.paymentMethod,
              amount: widget.total,
            );

            if (!paymentSuccess) {
              throw Exception('Payment processing failed');
            }

            // Create local order model
            final order = OrderModel(
              id: 'ORD-${wooOrder['id']}',
              items: cartItems,
              shippingAddress: widget.address,
              paymentMethod: widget.paymentMethod,
              subtotal: subtotal,
              shippingFee: shippingFee,
              tax: tax,
              total: widget.total,
            );

            // Check if widget is still mounted
            if (!mounted) return;

            // Clear cart
            cartBloc.add(const ClearCart());

            // Navigate to confirmation screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider.value(
                      value: cartBloc,
                      child: OrderConfirmationScreen(order: order),
                    ),
              ),
              (route) => false,
            );
          } catch (apiError) {
            debugPrint('❌ WooCommerce API error: $apiError');

            // Check if widget is still mounted
            if (!mounted) return;

            // Fallback to local order if API fails
            AnimatedToast.show(
              context: context,
              message: 'Using offline mode for checkout',
              type: ToastType.warning,
            );

            // Create local order model with offline ID
            final order = OrderModel(
              id: 'ORD-OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
              items: cartItems,
              shippingAddress: widget.address,
              paymentMethod: widget.paymentMethod,
              subtotal: subtotal,
              shippingFee: shippingFee,
              tax: tax,
              total: widget.total,
            );

            // Add to pending orders for later sync
            await orderSyncService.addPendingOrder(order);

            // Clear cart
            cartBloc.add(const ClearCart());

            // Check if widget is still mounted before navigation
            if (!mounted) return;

            // Navigate to confirmation screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (context) => BlocProvider.value(
                      value: cartBloc,
                      child: OrderConfirmationScreen(order: order),
                    ),
              ),
              (route) => false,
            );
          }
        } else {
          // Offline mode
          if (!mounted) return;

          AnimatedToast.show(
            context: context,
            message: 'Using offline mode for checkout',
            type: ToastType.warning,
          );

          // Create local order model with offline ID
          final order = OrderModel(
            id: 'ORD-OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
            items: cartItems,
            shippingAddress: widget.address,
            paymentMethod: widget.paymentMethod,
            subtotal: subtotal,
            shippingFee: shippingFee,
            tax: tax,
            total: widget.total,
          );

          // Add to pending orders for later sync
          await orderSyncService.addPendingOrder(order);

          // Clear cart
          cartBloc.add(const ClearCart());

          // Check if widget is still mounted before navigation
          if (!mounted) return;

          // Navigate to confirmation screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider.value(
                    value: cartBloc,
                    child: OrderConfirmationScreen(order: order),
                  ),
            ),
            (route) => false,
          );
        }
      } else {
        if (!mounted) return;
        AnimatedToast.show(
          context: context,
          message: 'Error: Cart data not available',
          type: ToastType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AnimatedToast.show(
        context: context,
        message: 'Error: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }
}
