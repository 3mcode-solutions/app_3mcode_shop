import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/colors.dart'; // TODO: Replace with AppTheme in the future
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';
import 'package:app_3mcode_shop/presentation/screens/product/product_detail_screen.dart';
import 'package:app_3mcode_shop/presentation/screens/checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                  tooltip: 'Clear cart',
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const LoadingIndicator(message: 'Loading cart...');
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyCart(context);
            } else {
              return Column(
                children: [
                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = state.items[index];
                        return CartItemCard(
                          cartItem: cartItem,
                          onRemove: () {
                            context.read<CartBloc>().add(
                              RemoveFromCart(cartItem.product),
                            );
                            AnimatedToast.show(
                              context: context,
                              message:
                                  '${cartItem.product.name} removed from cart',
                              type: ToastType.info,
                            );
                          },
                          onIncrement: () {
                            context.read<CartBloc>().add(
                              IncrementCartItemQuantity(cartItem.product),
                            );
                            AnimatedToast.show(
                              context: context,
                              message: 'Quantity increased',
                              type: ToastType.success,
                            );
                          },
                          onDecrement: () {
                            context.read<CartBloc>().add(
                              DecrementCartItemQuantity(cartItem.product),
                            );
                            if (cartItem.quantity > 1) {
                              AnimatedToast.show(
                                context: context,
                                message: 'Quantity decreased',
                                type: ToastType.info,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),

                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Subtotal',
                          '\$${state.totalPriceString}',
                        ),
                        _buildSummaryRow(
                          'Discount',
                          '-\$${state.totalSavingsString}',
                          isDiscount: true,
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total',
                          '\$${state.totalDiscountedPriceString}',
                          isTotal: true,
                        ),
                        const SizedBox(height: 16),
                        AnimatedButton(
                          text: 'Proceed to Checkout',
                          icon: Icons.shopping_bag,
                          onPressed: () {
                            AnimatedToast.show(
                              context: context,
                              message: 'Proceeding to checkout...',
                              type: ToastType.info,
                            );

                            // Navigate to checkout screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          } else if (state is CartError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<CartBloc>().add(const LoadCart());
              },
            );
          } else {
            return _buildEmptyCart(context);
          }
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to your cart to start shopping',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          AnimatedButton(
            text: 'Start Shopping',
            icon: Icons.shopping_basket,
            onPressed: () {
              AnimatedToast.show(
                context: context,
                message: 'Let\'s find some products for you!',
                type: ToastType.info,
              );

              // Navigate to products screen
              // In a real app, we would use a more sophisticated navigation approach
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<CartBloc>().add(const ClearCart());
                  Navigator.of(context).pop();

                  // Show success toast
                  AnimatedToast.show(
                    context: context,
                    message: 'Cart cleared successfully',
                    type: ToastType.success,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
