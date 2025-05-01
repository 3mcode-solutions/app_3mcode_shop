import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

/// Event to load cart items
class LoadCart extends CartEvent {
  const LoadCart();
}

/// Event to add product to cart
class AddToCart extends CartEvent {
  final ProductModel product;
  final int quantity;

  const AddToCart(this.product, {this.quantity = 1});

  @override
  List<Object> get props => [product, quantity];
}

/// Event to remove product from cart
class RemoveFromCart extends CartEvent {
  final ProductModel product;

  const RemoveFromCart(this.product);

  @override
  List<Object> get props => [product];
}

/// Event to update product quantity in cart
class UpdateCartItemQuantity extends CartEvent {
  final ProductModel product;
  final int quantity;

  const UpdateCartItemQuantity(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}

/// Event to increment product quantity in cart
class IncrementCartItemQuantity extends CartEvent {
  final ProductModel product;

  const IncrementCartItemQuantity(this.product);

  @override
  List<Object> get props => [product];
}

/// Event to decrement product quantity in cart
class DecrementCartItemQuantity extends CartEvent {
  final ProductModel product;

  const DecrementCartItemQuantity(this.product);

  @override
  List<Object> get props => [product];
}

/// Event to clear cart
class ClearCart extends CartEvent {
  const ClearCart();
}
