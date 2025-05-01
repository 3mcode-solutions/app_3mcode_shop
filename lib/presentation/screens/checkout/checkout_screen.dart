import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart';
import 'package:app_3mcode_shop/core/utils/validators.dart';
import 'package:app_3mcode_shop/data/models/address_model.dart';
import 'package:app_3mcode_shop/data/models/payment_method_model.dart';
import 'package:app_3mcode_shop/data/repositories/cart_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_state.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_event.dart';
import 'package:app_3mcode_shop/presentation/screens/checkout/payment_screen.dart';
import 'package:app_3mcode_shop/presentation/widgets/custom_app_bar.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_button.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_text_field.dart';
import 'package:app_3mcode_shop/presentation/widgets/animated_toast.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Selected payment method
  PaymentMethodModel? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Set default payment method
    _selectedPaymentMethod = PaymentMethodModel.getPredefinedMethods().first;

    // Pre-fill form with demo data for testing
    _fullNameController.text = 'John Doe';
    _phoneController.text = '123-456-7890';
    _addressLine1Controller.text = '123 Main St';
    _cityController.text = 'New York';
    _stateController.text = 'NY';
    _zipCodeController.text = '10001';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Checkout', showBackButton: true),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            final cartItems = state.items;
            final subtotal = cartItems.fold(
              0.0,
              (sum, item) => sum + item.totalDiscountedPrice,
            );
            final shippingFee = 5.99;
            final tax = subtotal * 0.05; // 5% tax
            final total = subtotal + shippingFee + tax;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Form
                  _buildSectionTitle('Shipping Address'),
                  _buildAddressForm(),

                  const SizedBox(height: 24),

                  // Payment Method Selection
                  _buildSectionTitle('Payment Method'),
                  _buildPaymentMethodSelection(),

                  const SizedBox(height: 24),

                  // Order Summary
                  _buildSectionTitle('Order Summary'),
                  _buildOrderSummary(
                    cartItems.length,
                    subtotal,
                    shippingFee,
                    tax,
                    total,
                  ),

                  const SizedBox(height: 24),

                  // Place Order Button
                  AnimatedButton(
                    text: 'Proceed to Payment',
                    icon: Icons.payment,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AnimatedToast.show(
                          context: context,
                          message: 'Proceeding to payment...',
                          type: ToastType.info,
                        );

                        Future.delayed(const Duration(milliseconds: 500), () {
                          _proceedToPayment(total);
                        });
                      } else {
                        AnimatedToast.show(
                          context: context,
                          message: 'Please fill all required fields correctly',
                          type: ToastType.error,
                        );
                      }
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

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AnimatedTextField(
            controller: _fullNameController,
            label: 'Full Name',
            prefixIcon: Icons.person,
            isRequired: true,
            validator: Validators.validateName,
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            controller: _phoneController,
            label: 'Phone Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            isRequired: true,
            validator: Validators.validatePhone,
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1',
            prefixIcon: Icons.home,
            isRequired: true,
            validator: Validators.validateAddress,
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2 (Optional)',
            prefixIcon: Icons.home,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedTextField(
                  controller: _cityController,
                  label: 'City',
                  prefixIcon: Icons.location_city,
                  isRequired: true,
                  validator: Validators.validateCity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedTextField(
                  controller: _stateController,
                  label: 'State',
                  prefixIcon: Icons.map,
                  isRequired: true,
                  validator: Validators.validateState,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedTextField(
            controller: _zipCodeController,
            label: 'ZIP Code',
            prefixIcon: Icons.markunread_mailbox,
            keyboardType: TextInputType.number,
            isRequired: true,
            validator: Validators.validateZipCode,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    final paymentMethods = PaymentMethodModel.getPredefinedMethods();

    return Column(
      children:
          paymentMethods.map((method) {
            final isSelected = _selectedPaymentMethod?.id == method.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method.description,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        method.type == PaymentType.cashOnDelivery
                            ? Icons.money
                            : Icons.credit_card,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOrderSummary(
    int itemCount,
    double subtotal,
    double shippingFee,
    double tax,
    double total,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow(
              'Items ($itemCount)',
              '\$${subtotal.toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildSummaryRow('Shipping', '\$${shippingFee.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow('Tax (5%)', '\$${tax.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total',
              '\$${total.toStringAsFixed(2)}',
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

  void _proceedToPayment(double total) {
    if (_formKey.currentState!.validate()) {
      try {
        // Create address model
        final address = AddressModel(
          fullName: _fullNameController.text,
          phoneNumber: _phoneController.text,
          addressLine1: _addressLine1Controller.text,
          addressLine2: _addressLine2Controller.text,
          city: _cityController.text,
          state: _stateController.text,
          zipCode: _zipCodeController.text,
        );

        // Navigate to payment screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BlocProvider.value(
                  value: BlocProvider.of<CartBloc>(context),
                  child: PaymentScreen(
                    address: address,
                    paymentMethod: _selectedPaymentMethod!,
                    total: total,
                  ),
                ),
          ),
        );
      } catch (e) {
        // Show error toast
        AnimatedToast.show(
          context: context,
          message: 'Error: ${e.toString()}',
          type: ToastType.error,
        );
        print('Error in _proceedToPayment: ${e.toString()}');
      }
    }
  }
}
