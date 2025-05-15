import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_3mcode_shop/data/models/order_model.dart';
import 'package:app_3mcode_shop/data/services/woo_checkout_service.dart';

/// Service for synchronizing offline orders when internet connection is restored
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

  // Services
  final WooCheckoutService _wooCheckoutService = WooCheckoutService();
  
  // Connectivity subscription
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Key for storing pending orders in SharedPreferences
  final String _pendingOrdersKey = 'pending_orders';
  
  /// Initialize connectivity subscription
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
  
  /// Dispose connectivity subscription
  void dispose() {
    _connectivitySubscription?.cancel();
  }
  
  /// Add order to pending orders list
  Future<void> addPendingOrder(OrderModel order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing pending orders
      final pendingOrders = await getPendingOrders();
      
      // Add new order
      pendingOrders.add(order);
      
      // Convert orders to JSON
      final ordersJson = pendingOrders
          .map((order) => order.toJson())
          .toList();
      
      // Save to SharedPreferences
      await prefs.setString(_pendingOrdersKey, json.encode(ordersJson));
      
      debugPrint('✅ Added order to pending orders: ${order.id}');
    } catch (e) {
      debugPrint('❌ Error adding pending order: $e');
    }
  }
  
  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get pending orders JSON
      final ordersJson = prefs.getString(_pendingOrdersKey);
      if (ordersJson == null) {
        return [];
      }
      
      // Parse JSON
      final ordersList = json.decode(ordersJson) as List<dynamic>;
      
      // Convert to OrderModel list
      return ordersList
          .map((orderJson) => OrderModel.fromJson(orderJson))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting pending orders: $e');
      return [];
    }
  }
  
  /// Remove order from pending orders
  Future<void> removePendingOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing pending orders
      final pendingOrders = await getPendingOrders();
      
      // Remove order
      pendingOrders.removeWhere((order) => order.id == orderId);
      
      // Convert orders to JSON
      final ordersJson = pendingOrders
          .map((order) => order.toJson())
          .toList();
      
      // Save to SharedPreferences
      await prefs.setString(_pendingOrdersKey, json.encode(ordersJson));
      
      debugPrint('✅ Removed order from pending orders: $orderId');
    } catch (e) {
      debugPrint('❌ Error removing pending order: $e');
    }
  }
  
  /// Sync pending orders with WooCommerce
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
  
  /// Manually trigger sync of pending orders
  Future<void> syncPendingOrders() async {
    return _syncPendingOrders();
  }
  
  /// Check if there are pending orders
  Future<bool> hasPendingOrders() async {
    final pendingOrders = await getPendingOrders();
    return pendingOrders.isNotEmpty;
  }
  
  /// Get count of pending orders
  Future<int> getPendingOrdersCount() async {
    final pendingOrders = await getPendingOrders();
    return pendingOrders.length;
  }
}
