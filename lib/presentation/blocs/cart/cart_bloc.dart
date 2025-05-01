import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/cart_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  
  CartBloc({
    required CartRepository cartRepository,
  }) : _cartRepository = cartRepository,
       super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<IncrementCartItemQuantity>(_onIncrementCartItemQuantity);
    on<DecrementCartItemQuantity>(_onDecrementCartItemQuantity);
    on<ClearCart>(_onClearCart);
  }
  
  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.addToCart(event.product, quantity: event.quantity);
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.removeFromCart(event.product);
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.updateQuantity(event.product, event.quantity);
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onIncrementCartItemQuantity(
    IncrementCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.incrementQuantity(event.product);
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onDecrementCartItemQuantity(
    DecrementCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.decrementQuantity(event.product);
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    
    try {
      await _cartRepository.clearCart();
      await _loadCartData(emit);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
  
  /// Helper method to load cart data and emit CartLoaded state
  Future<void> _loadCartData(Emitter<CartState> emit) async {
    final items = await _cartRepository.getCartItems();
    final totalPrice = await _cartRepository.getTotalPrice();
    final totalDiscountedPrice = await _cartRepository.getTotalDiscountedPrice();
    final totalSavings = await _cartRepository.getTotalSavings();
    final itemCount = await _cartRepository.getItemCount();
    final totalQuantity = await _cartRepository.getTotalQuantity();
    
    emit(CartLoaded(
      items: items,
      totalPrice: totalPrice,
      totalDiscountedPrice: totalDiscountedPrice,
      totalSavings: totalSavings,
      itemCount: itemCount,
      totalQuantity: totalQuantity,
    ));
  }
}
