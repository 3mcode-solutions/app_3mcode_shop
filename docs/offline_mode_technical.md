# Technical Documentation for Offline Mode Feature

<p align="center">
  <img src="../assets/logo/logo.svg" alt="3MCode Shop Logo" width="150"/>
</p>

<p align="center">
  <a href="#architecture">Architecture</a> •
  <a href="#components">Components</a> •
  <a href="#data-flow">Data Flow</a> •
  <a href="#implementation-details">Implementation Details</a> •
  <a href="#error-handling">Error Handling</a> •
  <a href="#testing">Testing</a>
</p>

## <a id="architecture"></a>Architecture

The offline mode feature is built on a layered architecture that follows the principles of Clean Architecture. The feature is divided into the following layers:

1. **Presentation Layer**: UI components and state management
2. **Domain Layer**: Business logic and use cases
3. **Data Layer**: Data sources, repositories, and services

## <a id="components"></a>Components

### 1. Cache Service (CacheService)

The `CacheService` is responsible for caching API responses and managing cache expiration. It provides a unified interface for getting data from either the cache or the API, depending on the availability of an internet connection and the freshness of the cached data.

### 2. Order Synchronization Service (OrderSyncService)

The `OrderSyncService` is responsible for synchronizing pending orders when internet connection is restored. It listens for connectivity changes and automatically synchronizes pending orders when the device goes online.

### 3. Product Repository (ProductRepository)

The `ProductRepository` has been modified to use the `CacheService` for fetching products. It now supports offline mode by returning cached products when there is no internet connection.

### 4. Payment Screen (PaymentScreen)

The `PaymentScreen` has been modified to handle offline mode during the checkout process. It creates local orders when there is no internet connection and stores them for later synchronization.

### 5. Model Classes

Several model classes have been enhanced to support JSON serialization and deserialization, which is necessary for storing and retrieving data from the local cache:

- `ProductModel`
- `CartItemModel`
- `OrderModel`
- `AddressModel`
- `PaymentMethodModel`

## <a id="data-flow"></a>Data Flow

### Online Mode

1. User requests data (e.g., products)
2. Repository checks if data is in cache and not expired
3. If data is in cache and not expired, return cached data
4. If data is not in cache or expired, fetch from API
5. Cache the fetched data
6. Return the data to the user

### Offline Mode

1. User requests data (e.g., products)
2. Repository detects no internet connection
3. Repository returns data from cache
4. If data is not in cache, return empty result or error

### Order Creation

#### Online Mode
1. User completes checkout
2. Application creates order in WooCommerce
3. Application processes payment
4. Application creates local order model
5. Application clears cart
6. Application navigates to order confirmation screen

#### Offline Mode
1. User completes checkout
2. Application detects no internet connection
3. Application creates local order with offline ID
4. Application adds order to pending orders
5. Application clears cart
6. Application navigates to order confirmation screen

### Order Synchronization

1. Device regains internet connection
2. `OrderSyncService` detects connectivity change
3. `OrderSyncService` retrieves pending orders
4. For each pending order:
   - Create order in WooCommerce
   - Process payment
   - If successful, remove from pending orders
   - If failed, keep in pending orders for next attempt

## <a id="implementation-details"></a>Implementation Details

### Cache Service (CacheService)

The `CacheService` uses `SharedPreferences` to store cached data. Each cached item includes the data itself and an expiration timestamp. When retrieving data, the service checks if the data has expired and returns null if it has.

```dart
Future<dynamic> _getFromCache(String key) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if data exists in cache
    if (!prefs.containsKey(key)) {
      return null;
    }
    
    // Get cache data
    final cacheData = prefs.getString(key);
    if (cacheData == null) {
      return null;
    }
    
    // Parse cache data
    final cacheMap = json.decode(cacheData) as Map<String, dynamic>;
    
    // Check if cache is expired
    final expirationTime = DateTime.parse(cacheMap['expiration'] as String);
    if (DateTime.now().isAfter(expirationTime)) {
      // Cache expired, remove it
      await prefs.remove(key);
      return null;
    }
    
    // Return cached data
    return cacheMap['data'];
  } catch (e) {
    debugPrint('❌ Error getting data from cache: $e');
    return null;
  }
}
```

### Order Synchronization Service (OrderSyncService)

The `OrderSyncService` uses `Connectivity` to listen for connectivity changes. When the device goes online, it retrieves pending orders from `SharedPreferences` and attempts to synchronize them with the WooCommerce server.

```dart
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

Future<void> _syncPendingOrders() async {
  try {
    // Get pending orders
    final pendingOrders = await getPendingOrders();
    
    if (pendingOrders.isEmpty) {
      return;
    }
    
    debugPrint('🔄 Syncing ${pendingOrders.length} pending orders...');
    
    // Sync each order
    for (final order in pendingOrders) {
      try {
        // Create order in WooCommerce
        final wooOrder = await _wooCheckoutService.createOrder(
          items: order.items,
          shippingAddress: order.shippingAddress,
          paymentMethod: order.paymentMethod,
          subtotal: order.subtotal,
          shippingFee: order.shippingFee,
          tax: order.tax,
          total: order.total,
        );
        
        // Process payment
        final paymentSuccess = await _wooCheckoutService.processPayment(
          orderId: wooOrder['id'].toString(),
          paymentMethod: order.paymentMethod,
          amount: order.total,
        );
        
        if (paymentSuccess) {
          // Remove from pending orders
          await removePendingOrder(order.id);
          debugPrint('✅ Successfully synced order: ${order.id}');
        } else {
          debugPrint('❌ Failed to process payment for order: ${order.id}');
        }
      } catch (e) {
        debugPrint('❌ Error syncing order ${order.id}: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error syncing pending orders: $e');
  }
}
```

### Model Classes

Model classes have been enhanced to support JSON serialization and deserialization. For example, the `OrderModel` class now includes `toJson` and `fromJson` methods:

```dart
// Convert OrderModel to JSON
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'items': items.map((item) => item.toJson()).toList(),
    'shippingAddress': shippingAddress.toJson(),
    'paymentMethod': paymentMethod.toJson(),
    'subtotal': subtotal,
    'shippingFee': shippingFee,
    'tax': tax,
    'total': total,
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

// Create OrderModel from JSON
factory OrderModel.fromJson(Map<String, dynamic> json) {
  return OrderModel(
    id: json['id'] as String,
    items: (json['items'] as List<dynamic>)
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList(),
    shippingAddress: AddressModel.fromJson(
      json['shippingAddress'] as Map<String, dynamic>,
    ),
    paymentMethod: PaymentMethodModel.fromJson(
      json['paymentMethod'] as Map<String, dynamic>,
    ),
    subtotal: json['subtotal'] as double,
    shippingFee: json['shippingFee'] as double,
    tax: json['tax'] as double,
    total: json['total'] as double,
    status: OrderStatus.values[json['status'] as int],
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
  );
}
```

## <a id="error-handling"></a>Error Handling

### Cache Service

The `CacheService` handles errors that may occur during cache operations. If an error occurs while retrieving data from the cache, the service returns null, which triggers a fetch from the API if internet is available.

### Order Synchronization Service

The `OrderSyncService` handles errors that may occur during order synchronization. If an error occurs while synchronizing an order, the service keeps the order in the pending orders list for the next synchronization attempt.

### Payment Screen

The `PaymentScreen` handles errors that may occur during the checkout process. If an error occurs while creating an order in WooCommerce, the screen falls back to creating a local order and storing it for later synchronization.

## <a id="testing"></a>Testing

The offline mode feature has been tested in the following scenarios:

1. **Online Mode**: Verify that the application works correctly when internet connection is available
2. **Offline Mode**: Verify that the application works correctly when internet connection is not available
3. **Transition from Online to Offline**: Verify that the application handles the transition from online to offline mode correctly
4. **Transition from Offline to Online**: Verify that the application handles the transition from offline to online mode correctly and synchronizes pending orders

### Test Results

- **Online Mode**: The application successfully fetches data from the API and creates orders in WooCommerce
- **Offline Mode**: The application successfully uses cached data and creates local orders
- **Transition from Online to Offline**: The application successfully detects the loss of internet connection and switches to offline mode
- **Transition from Offline to Online**: The application successfully detects the restoration of internet connection and synchronizes pending orders
