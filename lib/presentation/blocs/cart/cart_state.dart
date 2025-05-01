import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/cart_item_model.dart';

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object> get props => [];
}

/// Initial state when cart has not been loaded yet
class CartInitial extends CartState {
  const CartInitial();
}

/// State when cart is being loaded
class CartLoading extends CartState {
  const CartLoading();
}

/// State when cart has been loaded successfully
class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;
  final double totalDiscountedPrice;
  final double totalSavings;
  final int itemCount;
  final int totalQuantity;
  
  const CartLoaded({
    required this.items,
    required this.totalPrice,
    required this.totalDiscountedPrice,
    required this.totalSavings,
    required this.itemCount,
    required this.totalQuantity,
  });
  
  @override
  List<Object> get props => [
    items,
    totalPrice,
    totalDiscountedPrice,
    totalSavings,
    itemCount,
    totalQuantity,
  ];
  
  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;
  
  /// Format total price as string with 2 decimal places
  String get totalPriceString => totalPrice.toStringAsFixed(2);
  
  /// Format total discounted price as string with 2 decimal places
  String get totalDiscountedPriceString => totalDiscountedPrice.toStringAsFixed(2);
  
  /// Format total savings as string with 2 decimal places
  String get totalSavingsString => totalSavings.toStringAsFixed(2);
}

/// State when there was an error with the cart
class CartError extends CartState {
  final String message;
  
  const CartError(this.message);
  
  @override
  List<Object> get props => [message];
}
