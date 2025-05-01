# إدارة الحالة في تطبيق 3MCode Shop

<p align="center">
  <img src="assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#overview">نظرة عامة</a> •
  <a href="#bloc-pattern">نمط BLoC</a> •
  <a href="#bloc-components">مكونات BLoC</a> •
  <a href="#bloc-implementation">تنفيذ BLoC</a> •
  <a href="#state-flow">تدفق الحالة</a> •
  <a href="#examples">أمثلة</a>
</p>

## <a id="overview"></a>نظرة عامة

يستخدم تطبيق 3MCode Shop نمط BLoC (Business Logic Component) لإدارة حالة التطبيق. يوفر هذا النمط فصلاً واضحًا بين واجهة المستخدم ومنطق الأعمال، مما يجعل التطبيق أكثر قابلية للاختبار والصيانة والتوسع.

### مميزات استخدام BLoC

- **فصل المسؤوليات**: فصل واضح بين واجهة المستخدم ومنطق الأعمال.
- **قابلية الاختبار**: يمكن اختبار منطق الأعمال بشكل مستقل عن واجهة المستخدم.
- **إعادة استخدام الكود**: يمكن إعادة استخدام نفس منطق الأعمال في أجزاء مختلفة من التطبيق.
- **تدفق البيانات أحادي الاتجاه**: تدفق واضح للبيانات من واجهة المستخدم إلى BLoC وبالعكس.
- **إدارة الحالة المعقدة**: يسهل إدارة الحالات المعقدة والمتغيرة.

## <a id="bloc-pattern"></a>نمط BLoC

### المفاهيم الأساسية

1. **الأحداث (Events)**: تمثل الأحداث التي تحدث في التطبيق، مثل النقر على زر أو تحميل البيانات.
2. **الحالات (States)**: تمثل حالة التطبيق في لحظة معينة، مثل حالة التحميل أو الخطأ أو النجاح.
3. **BLoC**: يتلقى الأحداث ويعالجها وينتج حالات جديدة.

### تدفق البيانات

```
واجهة المستخدم (UI) -> أحداث (Events) -> BLoC -> حالات (States) -> واجهة المستخدم (UI)
```

## <a id="bloc-components"></a>مكونات BLoC

### 1. الأحداث (Events)

الأحداث هي مدخلات BLoC وتمثل الأحداث التي تحدث في التطبيق. يجب أن تكون الأحداث غير قابلة للتغيير (immutable).

```dart
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class LoadProductsByCategory extends ProductEvent {
  final String categoryName;

  const LoadProductsByCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}
```

### 2. الحالات (States)

الحالات هي مخرجات BLoC وتمثل حالة التطبيق في لحظة معينة. يجب أن تكون الحالات غير قابلة للتغيير (immutable).

```dart
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
```

### 3. BLoC

BLoC هو المكون الذي يتلقى الأحداث ويعالجها وينتج حالات جديدة.

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  
  ProductBloc({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository,
       super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
  }
  
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
  
  // المزيد من معالجات الأحداث...
}
```

## <a id="bloc-implementation"></a>تنفيذ BLoC

### 1. تعريف BLoC

```dart
// lib/presentation/blocs/product/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/product_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  
  ProductBloc({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository,
       super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
  }
  
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
  
  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      final products = await _productRepository.getProductsByCategory(event.categoryName);
      emit(ProductsByCategoryLoaded(
        products: products,
        categoryName: event.categoryName,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
  
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      final products = await _productRepository.searchProducts(event.query);
      emit(ProductSearchResults(
        products: products,
        query: event.query,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
```

### 2. توفير BLoC

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/repositories.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/screens/screens.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create:
              (context) =>
                  ProductBloc(productRepository: ProductRepository())
                    ..add(const LoadProducts()),
        ),
        BlocProvider<CategoryBloc>(
          create:
              (context) =>
                  CategoryBloc(categoryRepository: CategoryRepository())
                    ..add(const LoadCategories()),
        ),
        // المزيد من BLoC providers...
      ],
      child: // ...
    );
  }
}
```

### 3. استخدام BLoC في واجهة المستخدم

```dart
// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/presentation/blocs/blocs.dart';
import 'package:app_3mcode_shop/presentation/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ...
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const LoadingIndicator();
                } else if (state is ProductLoaded) {
                  return ProductGrid(products: state.products);
                } else if (state is ProductError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: () => context.read<ProductBloc>().add(const LoadProducts()),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            // ...
          ],
        ),
      ),
    );
  }
}
```

## <a id="state-flow"></a>تدفق الحالة

### 1. تدفق الحالة العام

```
واجهة المستخدم (UI) -> أحداث (Events) -> BLoC -> حالات (States) -> واجهة المستخدم (UI)
```

### 2. مثال على تدفق الحالة: تحميل المنتجات

1. **واجهة المستخدم**: تعرض شاشة المنتجات.
2. **الحدث**: يتم إرسال حدث `LoadProducts` إلى `ProductBloc`.
3. **BLoC**: يتلقى `ProductBloc` الحدث ويطلب البيانات من `ProductRepository`.
4. **المستودع**: يجلب `ProductRepository` البيانات من `LocalData`.
5. **BLoC**: ينتج `ProductBloc` حالة `ProductLoaded` مع قائمة المنتجات.
6. **واجهة المستخدم**: تتحدث الشاشة لعرض المنتجات.

### 3. مثال على تدفق الحالة: إضافة منتج إلى سلة التسوق

1. **واجهة المستخدم**: يضغط المستخدم على زر "أضف إلى السلة".
2. **الحدث**: يتم إرسال حدث `AddToCart` إلى `CartBloc`.
3. **BLoC**: يتلقى `CartBloc` الحدث ويطلب إضافة المنتج من `CartRepository`.
4. **المستودع**: يضيف `CartRepository` المنتج إلى سلة التسوق في `LocalData`.
5. **BLoC**: ينتج `CartBloc` حالة `CartLoaded` مع قائمة المنتجات المحدثة.
6. **واجهة المستخدم**: تتحدث الشاشة لعرض رسالة تأكيد وتحديث عداد السلة.

## <a id="examples"></a>أمثلة

### 1. مثال: إدارة سلة التسوق

#### الأحداث

```dart
// lib/presentation/blocs/cart/cart_event.dart
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {
  const LoadCart();
}

class AddToCart extends CartEvent {
  final ProductModel product;
  final int quantity;

  const AddToCart({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object> get props => [product, quantity];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object> get props => [productId];
}

class UpdateCartItemQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItemQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}
```

#### الحالات

```dart
// lib/presentation/blocs/cart/cart_state.dart
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final int totalQuantity;

  const CartLoaded({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.totalQuantity,
  });

  @override
  List<Object> get props => [items, subtotal, tax, shipping, total, totalQuantity];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}
```

#### BLoC

```dart
// lib/presentation/blocs/cart/cart_bloc.dart
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
      await _cartRepository.addToCart(event.product, event.quantity);
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
      await _cartRepository.removeFromCart(event.productId);
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
      await _cartRepository.updateCartItemQuantity(event.productId, event.quantity);
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
  
  Future<void> _loadCartData(Emitter<CartState> emit) async {
    final items = await _cartRepository.getCartItems();
    final subtotal = await _cartRepository.getSubtotal();
    final tax = await _cartRepository.getTax();
    final shipping = await _cartRepository.getShipping();
    final total = await _cartRepository.getTotal();
    final totalQuantity = await _cartRepository.getTotalQuantity();
    
    emit(CartLoaded(
      items: items,
      subtotal: subtotal,
      tax: tax,
      shipping: shipping,
      total: total,
      totalQuantity: totalQuantity,
    ));
  }
}
```

#### استخدام BLoC في واجهة المستخدم

```dart
// lib/presentation/screens/cart/cart_screen.dart
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearCartConfirmation(context),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const LoadingIndicator();
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const EmptyCartView();
            }
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = state.items[index];
                      return CartItemCard(
                        cartItem: cartItem,
                        onIncrement: () => _incrementQuantity(context, cartItem),
                        onDecrement: () => _decrementQuantity(context, cartItem),
                        onRemove: () => _removeFromCart(context, cartItem),
                      );
                    },
                  ),
                ),
                CartSummary(
                  subtotal: state.subtotal,
                  tax: state.tax,
                  shipping: state.shipping,
                  total: state.total,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedButton(
                    text: 'متابعة الدفع',
                    onPressed: () => _proceedToCheckout(context),
                  ),
                ),
              ],
            );
          } else if (state is CartError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<CartBloc>().add(const LoadCart()),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
  
  void _incrementQuantity(BuildContext context, CartItemModel cartItem) {
    context.read<CartBloc>().add(
      UpdateCartItemQuantity(
        productId: cartItem.product.id,
        quantity: cartItem.quantity + 1,
      ),
    );
  }
  
  void _decrementQuantity(BuildContext context, CartItemModel cartItem) {
    if (cartItem.quantity > 1) {
      context.read<CartBloc>().add(
        UpdateCartItemQuantity(
          productId: cartItem.product.id,
          quantity: cartItem.quantity - 1,
        ),
      );
    } else {
      _removeFromCart(context, cartItem);
    }
  }
  
  void _removeFromCart(BuildContext context, CartItemModel cartItem) {
    context.read<CartBloc>().add(
      RemoveFromCart(cartItem.product.id),
    );
  }
  
  void _showClearCartConfirmation(BuildContext context) {
    // ...
  }
  
  void _proceedToCheckout(BuildContext context) {
    // ...
  }
}
```

### 2. مثال: إدارة اللغة

#### الأحداث

```dart
// lib/presentation/blocs/language/language_event.dart
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  final Locale locale;

  const ChangeLanguage(this.locale);

  @override
  List<Object> get props => [locale];
}
```

#### الحالات

```dart
// lib/presentation/blocs/language/language_state.dart
abstract class LanguageState extends Equatable {
  const LanguageState();
  
  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();
}

class LanguageLoading extends LanguageState {
  const LanguageLoading();
}

class LanguageLoaded extends LanguageState {
  final Locale locale;
  
  const LanguageLoaded(this.locale);
  
  @override
  List<Object> get props => [locale];
}

class LanguageError extends LanguageState {
  final String message;
  
  const LanguageError(this.message);
  
  @override
  List<Object> get props => [message];
}
```

#### BLoC

```dart
// lib/presentation/blocs/language/language_bloc.dart
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageManager _languageManager = LanguageManager();
  
  LanguageBloc() : super(const LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }
  
  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(const LanguageLoading());
    try {
      final locale = await _languageManager.getLocale();
      emit(LanguageLoaded(locale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
  
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(const LanguageLoading());
    try {
      await _languageManager.setLocale(event.locale);
      emit(LanguageLoaded(event.locale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
}
```

#### استخدام BLoC في واجهة المستخدم

```dart
// lib/presentation/screens/settings/language_screen.dart
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('language')),
      ),
      body: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          if (state is LanguageLoading) {
            return const LoadingIndicator();
          } else if (state is LanguageLoaded) {
            final currentLocale = state.locale;
            
            return ListView(
              children: [
                ListTile(
                  title: const Text('English'),
                  leading: const Text('🇺🇸'),
                  trailing: currentLocale.languageCode == 'en'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => _changeLanguage(context, const Locale('en')),
                ),
                ListTile(
                  title: const Text('العربية'),
                  leading: const Text('🇸🇦'),
                  trailing: currentLocale.languageCode == 'ar'
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => _changeLanguage(context, const Locale('ar')),
                ),
              ],
            );
          } else if (state is LanguageError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<LanguageBloc>().add(const LoadLanguage()),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
  
  void _changeLanguage(BuildContext context, Locale locale) {
    context.read<LanguageBloc>().add(ChangeLanguage(locale));
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('language_changed')),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
```

---

<p align="center">
  تم التطوير بواسطة <a href="https://www.3mcode.com">3MCode</a> - جميع الحقوق محفوظة © 2025
</p>
