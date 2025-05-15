# Offline Mode Feature in 3MCode Shop Application

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#features">Features</a> •
  <a href="#implementation">Implementation</a> •
  <a href="#user-experience">User Experience</a> •
  <a href="#technical-details">Technical Details</a> •
  <a href="#future-improvements">Future Improvements</a>
</p>

## <a id="overview"></a>Overview

The offline mode feature allows users to use the 3MCode Shop application even when they don't have an internet connection. Users can browse products, add them to the shopping cart, and even complete the checkout process in offline mode. When the user regains internet connection, pending orders are automatically synchronized with the WooCommerce server.

## <a id="features"></a>Features

### Browse Products in Offline Mode
- View locally stored products
- Search and filter products offline
- View complete product details

### Manage Shopping Cart in Offline Mode
- Add products to the shopping cart
- Adjust product quantities in the cart
- Remove products from the cart
- Calculate subtotal, taxes, and shipping fees

### Complete Checkout in Offline Mode
- Enter shipping information
- Select payment method
- Create a local order
- Store the order locally for later synchronization

### Synchronize Orders When Connection is Restored
- Automatically synchronize pending orders when internet connection is restored
- Notify the user of synchronization status
- Handle errors and recovery

## <a id="implementation"></a>Implementation

The offline mode feature was implemented using the following components:

### 1. Cache Service (CacheService)
A new service was created to cache API responses and manage cache expiration. This service uses `SharedPreferences` to store data locally.

### 2. Order Synchronization Service (OrderSyncService)
A new service was created to synchronize pending orders when internet connection is restored. This service uses `Connectivity` to listen for connection changes and `SharedPreferences` to store pending orders.

### 3. Product Repository Modification (ProductRepository)
The product repository was modified to use the cache service and provide support for offline mode.

### 4. Payment Screen Modification (PaymentScreen)
The payment screen was modified to handle offline mode and create local orders when needed.

## <a id="user-experience"></a>User Experience

### Offline Mode Notifications
- The user is notified when the application is in offline mode
- The user is notified when an order is created in offline mode
- The user is notified when pending orders are synchronized

### Seamless Experience
- The user can continue to use the application normally in offline mode
- There is no significant change in the user interface or workflow
- Errors and exceptions are handled appropriately

## <a id="technical-details"></a>Technical Details

### Cache Service (CacheService)

The cache service was implemented to cache API responses and manage cache expiration. This service uses `SharedPreferences` to store data locally.

```dart
class CacheService {
  // Singleton pattern
  static final CacheService _instance = CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  // Cache expiration time (in minutes)
  final int _defaultCacheExpirationMinutes = 30;

  /// Get data from cache or API
  Future<dynamic> getOrFetchData({
    required String cacheKey,
    required Future<dynamic> Function() fetchFunction,
    int? cacheExpirationMinutes,
    bool forceRefresh = false,
  }) async {
    // Check internet connection
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivityResult != ConnectivityResult.none;

    // If no internet connection, always try to get from cache
    if (!hasInternet) {
      return await _getFromCache(cacheKey);
    }

    // If force refresh, always fetch from API
    if (forceRefresh) {
      return await _fetchAndCache(cacheKey, fetchFunction, cacheExpirationMinutes);
    }

    // Try to get from cache first
    final cachedData = await _getFromCache(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    // If not in cache or expired, fetch from API
    return await _fetchAndCache(cacheKey, fetchFunction, cacheExpirationMinutes);
  }
}
```

### Order Synchronization Service (OrderSyncService)

The order synchronization service was implemented to synchronize pending orders when internet connection is restored. This service uses `Connectivity` to listen for connection changes and `SharedPreferences` to store pending orders.

```dart
class OrderSyncService {
  // Singleton pattern
  static final OrderSyncService _instance = OrderSyncService._internal();

  factory OrderSyncService() {
    return _instance;
  }

  // Private constructor
  OrderSyncService._internal() {
    // Initialize connectivity subscription
    _initConnectivitySubscription();
  }

  // Connectivity subscription
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Initialize connectivity subscription
  void _initConnectivitySubscription() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Internet connection restored, sync pending orders
        _syncPendingOrders();
      }
    });
  }
}
```

## <a id="future-improvements"></a>Future Improvements

### User Experience Improvements
- Add connection status indicator in the user interface
- Add a screen to display pending orders
- Add an option to manually synchronize orders

### Performance Improvements
- Improve memory usage and data storage
- Improve synchronization performance
- Improve error handling and recovery

### Additional Features
- Support for favorites synchronization
- Support for settings synchronization
- Support for user information synchronization
