import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

/// A model class representing an item in the shopping cart
class CartItemModel extends Equatable {
  final ProductModel product;
  final int quantity;

  CartItemModel({required this.product, this.quantity = 1})
    : assert(quantity > 0, 'Quantity must be greater than 0');

  /// Calculate total price for this cart item
  double get totalPrice => product.priceAsDouble * quantity;

  /// Format total price as string with 2 decimal places
  String get totalPriceString => totalPrice.toStringAsFixed(2);

  /// Calculate total discounted price for this cart item
  double get totalDiscountedPrice => product.discountedPrice * quantity;

  /// Format total discounted price as string with 2 decimal places
  String get totalDiscountedPriceString =>
      totalDiscountedPrice.toStringAsFixed(2);

  /// Calculate savings amount
  double get savingsAmount => totalPrice - totalDiscountedPrice;

  /// Format savings amount as string with 2 decimal places
  String get savingsAmountString => savingsAmount.toStringAsFixed(2);

  @override
  List<Object> get props => [product, quantity];

  // Create a copy of this CartItemModel with the given fields replaced
  CartItemModel copyWith({ProductModel? product, int? quantity}) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // Increment quantity by 1
  CartItemModel incrementQuantity() {
    return copyWith(quantity: quantity + 1);
  }

  // Decrement quantity by 1, ensuring it doesn't go below 1
  CartItemModel decrementQuantity() {
    if (quantity <= 1) return this;
    return copyWith(quantity: quantity - 1);
  }
}
