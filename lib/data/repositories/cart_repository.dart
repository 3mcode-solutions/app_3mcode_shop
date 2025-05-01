import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/models.dart';

class CartRepository {
  // Singleton pattern
  static final CartRepository _instance = CartRepository._internal();

  factory CartRepository() {
    return _instance;
  }

  CartRepository._internal() {
    // Initialize cart items with some demo data
    _cartItems = LocalData.getInitialCartItems();
  }

  // In-memory storage for cart items
  late List<CartItemModel> _cartItems;

  /// Get all cart items
  ///
  /// This method simulates an API call by adding a delay
  Future<List<CartItemModel>> getCartItems() async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    return List.from(_cartItems);
  }

  /// Add product to cart
  ///
  /// If product already exists in cart, increase quantity
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (existingItemIndex >= 0) {
      // Product already in cart, increase quantity
      final existingItem = _cartItems[existingItemIndex];
      _cartItems[existingItemIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Product not in cart, add new item
      _cartItems.add(CartItemModel(product: product, quantity: quantity));
    }
  }

  /// Remove product from cart
  Future<void> removeFromCart(ProductModel product) async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    _cartItems.removeWhere((item) => item.product.name == product.name);
  }

  /// Update cart item quantity
  Future<void> updateQuantity(ProductModel product, int quantity) async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    if (quantity <= 0) {
      await removeFromCart(product);
      return;
    }

    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (existingItemIndex >= 0) {
      _cartItems[existingItemIndex] = _cartItems[existingItemIndex].copyWith(
        quantity: quantity,
      );
    }
  }

  /// Increment cart item quantity
  Future<void> incrementQuantity(ProductModel product) async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (existingItemIndex >= 0) {
      _cartItems[existingItemIndex] =
          _cartItems[existingItemIndex].incrementQuantity();
    }
  }

  /// Decrement cart item quantity
  Future<void> decrementQuantity(ProductModel product) async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.name == product.name,
    );

    if (existingItemIndex >= 0) {
      final updatedItem = _cartItems[existingItemIndex].decrementQuantity();

      if (updatedItem.quantity <= 0) {
        await removeFromCart(product);
      } else {
        _cartItems[existingItemIndex] = updatedItem;
      }
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);

    _cartItems.clear();
  }

  /// Check if product is in cart
  Future<bool> isInCart(ProductModel product) async {
    final cartItems = await getCartItems();

    return cartItems.any((item) => item.product.name == product.name);
  }

  /// Get cart total price
  Future<double> getTotalPrice() async {
    final cartItems = await getCartItems();

    return cartItems.fold<double>(
      0.0,
      (double total, item) => total + item.totalPrice,
    );
  }

  /// Get cart total discounted price
  Future<double> getTotalDiscountedPrice() async {
    final cartItems = await getCartItems();

    return cartItems.fold<double>(
      0.0,
      (double total, item) => total + item.totalDiscountedPrice,
    );
  }

  /// Get cart total savings
  Future<double> getTotalSavings() async {
    final cartItems = await getCartItems();

    return cartItems.fold<double>(
      0.0,
      (double total, item) => total + item.savingsAmount,
    );
  }

  /// Get cart item count
  Future<int> getItemCount() async {
    final cartItems = await getCartItems();

    return cartItems.length;
  }

  /// Get cart total quantity
  Future<int> getTotalQuantity() async {
    final cartItems = await getCartItems();

    return cartItems.fold<int>(0, (int total, item) => total + item.quantity);
  }
}
