# Technical Details of 3MCode Shop Project

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#state-management">State Management</a> •
  <a href="#data-models">Data Models</a> •
  <a href="#repositories">Repositories</a> •
  <a href="#services">Services</a> •
  <a href="#localization">Localization</a> •
  <a href="#theme">Theme Management</a> •
  <a href="#checkout">Checkout Process</a> •
  <a href="#favorites">Favorites</a> •
  <a href="#search">Search and Filtering</a>
</p>

## <a id="state-management"></a>State Management

The application uses the BLoC (Business Logic Component) pattern for state management, providing a clear separation between the user interface and business logic.

### BLoC Components

#### 1. Events

Events are inputs to BLoC and represent events that occur in the application. Events must be immutable.

```dart
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {
  const LoadProducts();
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}
```

#### 2. States

States are outputs from BLoC and represent the state of the application at a given moment. States must be immutable.

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
```

#### 3. BLoC

BLoC is the component that receives events, processes them, and produces new states.

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  
  ProductBloc({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository,
       super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
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
}
```

### Main BLoCs in the Application

1. **ProductBloc**: For managing product state (loading, searching, filtering).
2. **CartBloc**: For managing shopping cart state (adding, removing, adjusting quantity).
3. **FavoriteBloc**: For managing favorites state (adding, removing).
4. **LanguageBloc**: For managing language state (loading, changing).
5. **ThemeBloc**: For managing theme state (loading, changing).
6. **AuthBloc**: For managing authentication state (login, logout).

## <a id="data-models"></a>Data Models

### ProductModel

```dart
class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final String category;
  final bool isOnSale;
  final String discountPercentage;
  final String rate;
  final String rateCount;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.isOnSale = false,
    this.discountPercentage = '0',
    this.rate = '0',
    this.rateCount = '0',
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    price, 
    image, 
    category,
    isOnSale,
    discountPercentage,
    rate,
    rateCount,
  ];
  
  double get priceAsDouble => double.parse(price);
  double get discountPercentageAsDouble => double.parse(discountPercentage);
  double get discountedPrice => isOnSale 
    ? priceAsDouble - (priceAsDouble * discountPercentageAsDouble / 100)
    : priceAsDouble;
  double get rateAsDouble => double.parse(rate);
}
```

### CartItemModel

```dart
class CartItemModel extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, quantity];
  
  double get totalPrice => product.priceAsDouble * quantity;
  double get totalDiscountedPrice => product.discountedPrice * quantity;
  double get totalSavings => (product.priceAsDouble - product.discountedPrice) * quantity;
}
```

### OrderModel

```dart
class OrderModel extends Equatable {
  final String id;
  final List<CartItemModel> items;
  final AddressModel shippingAddress;
  final PaymentMethodModel paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.total,
    this.status = OrderStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
    id, 
    items, 
    shippingAddress, 
    paymentMethod, 
    subtotal, 
    shippingFee, 
    tax, 
    total,
    status,
    createdAt,
    updatedAt,
  ];
}
```

## <a id="repositories"></a>Repositories

### ProductRepository

```dart
class ProductRepository {
  /// Get all products
  Future<List<ProductModel>> getProducts() async {
    // In a real app, this would fetch from an API or local database
    return LocalData.getProducts();
  }
  
  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final products = await getProducts();
    return products.where(
      (product) => product.category.toLowerCase() == category.toLowerCase(),
    ).toList();
  }
  
  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) {
      return getProducts();
    }
    
    final products = await getProducts();
    final lowercaseQuery = query.toLowerCase();
    
    return products.where(
      (product) => product.name.toLowerCase().contains(lowercaseQuery),
    ).toList();
  }
}
```

### CartRepository

```dart
class CartRepository {
  final CartStorage _cartStorage = CartStorage();
  
  /// Get all cart items
  Future<List<CartItemModel>> getCartItems() async {
    return _cartStorage.getCartItems();
  }
  
  /// Add product to cart
  Future<bool> addToCart(ProductModel product, [int quantity = 1]) async {
    return _cartStorage.addToCart(product, quantity);
  }
  
  /// Remove product from cart
  Future<bool> removeFromCart(String productId) async {
    return _cartStorage.removeFromCart(productId);
  }
  
  /// Update cart item quantity
  Future<bool> updateCartItemQuantity(String productId, int quantity) async {
    return _cartStorage.updateCartItemQuantity(productId, quantity);
  }
  
  /// Clear cart
  Future<bool> clearCart() async {
    return _cartStorage.clearCart();
  }
}
```

## <a id="services"></a>Services

### FavoriteService

```dart
class FavoriteService {
  static const String _favoritesKey = 'favorites';
  
  // Get list of favorite product IDs
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesList;
  }
  
  // Get list of favorite products
  Future<List<ProductModel>> getFavoriteProducts() async {
    final favoriteIds = await getFavoriteIds();
    final allProducts = LocalData.getProducts();
    
    return allProducts.where((product) => favoriteIds.contains(product.id)).toList();
  }
  
  // Check if a product is favorite
  Future<bool> isFavorite(String productId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(productId);
  }
  
  // Add product to favorites
  Future<bool> addToFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    
    if (favoriteIds.contains(productId)) {
      return true; // Product already in favorites
    }
    
    favoriteIds.add(productId);
    return await prefs.setStringList(_favoritesKey, favoriteIds);
  }
  
  // Remove product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    
    if (!favoriteIds.contains(productId)) {
      return true; // Product not in favorites
    }
    
    favoriteIds.remove(productId);
    return await prefs.setStringList(_favoritesKey, favoriteIds);
  }
}
```

## <a id="localization"></a>Localization

### AppLocalizations

```dart
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  late Map<String, String> _localizedStrings;
  
  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    
    return true;
  }
  
  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
  
  // Get current locale
  Locale get currentLocale => locale;
  
  // Check if the current locale is RTL
  bool get isRtl => locale.languageCode == 'ar';
}
```

### LanguageManager

```dart
class LanguageManager {
  // Singleton instance
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();
  
  // Key for storing language preference
  static const String _languageKey = 'language_code';
  
  // Default language
  static const Locale defaultLocale = Locale('en');
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];
  
  // Get the current locale from shared preferences
  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_languageKey);
    
    if (languageCode == null) {
      return defaultLocale;
    }
    
    return Locale(languageCode);
  }
  
  // Save the selected locale to shared preferences
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
}
```

## <a id="theme"></a>Theme Management

### AppTheme

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // ... more theme configurations
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // ... more theme configurations
    );
  }
}
```

### ThemeManager

```dart
class ThemeManager {
  // Singleton instance
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();
  
  // Keys for storing theme preferences
  static const String _themeKey = 'is_dark_mode';
  static const String _followSystemKey = 'follow_system';
  
  // Get the current theme from shared preferences
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
  
  // Save the selected theme to shared preferences
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
    // When setting the theme manually, disable follow system option
    await prefs.setBool(_followSystemKey, false);
  }
  
  // Toggle the current theme
  Future<bool> toggleTheme() async {
    final isDark = await isDarkMode();
    await setDarkMode(!isDark);
    return !isDark;
  }
}
```

## <a id="checkout"></a>Checkout Process

### PaymentScreen

```dart
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
  double _progressValue = 0;
  late Timer _timer;

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
      appBar: CustomAppBar(
        title: 'Payment',
        showBackButton: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment method details
                  _buildPaymentMethodDetails(),
                  
                  const SizedBox(height: 24),
                  
                  // Order summary
                  _buildOrderSummary(state),
                  
                  const SizedBox(height: 24),
                  
                  // Payment progress
                  if (_isProcessing) _buildPaymentProgress(),
                  
                  const SizedBox(height: 24),
                  
                  // Pay Now Button
                  if (!_isProcessing)
                    AnimatedButton(
                      text: widget.paymentMethod.type == PaymentType.cashOnDelivery
                          ? 'Place Order'
                          : 'Pay Now',
                      icon: widget.paymentMethod.type == PaymentType.cashOnDelivery
                          ? Icons.local_shipping
                          : Icons.payment,
                      onPressed: () {
                        AnimatedToast.show(
                          context: context,
                          message: widget.paymentMethod.type == PaymentType.cashOnDelivery
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
  
  // ... more methods
}
```

## <a id="favorites"></a>Favorites

### FavoriteBloc

```dart
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteService _favoriteService = FavoriteService();
  
  FavoriteBloc() : super(const FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }
  
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(const FavoriteLoading());
    
    try {
      final favorites = await _favoriteService.getFavoriteProducts();
      final favoriteIds = await _favoriteService.getFavoriteIds();
      
      emit(FavoriteLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
  
  // ... more methods
}
```

## <a id="search"></a>Search and Filtering

### SearchScreen

```dart
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _minPrice = 0;
  double _maxPrice = 100;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('search')),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(localizations),
          _buildFilters(localizations),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                // ... more code
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // ... more methods
}
```

---

<p align="center">
  Developed by <a href="https://www.3mcode.com">3MCode</a> - All rights reserved © 2025
</p>
