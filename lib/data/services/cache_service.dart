import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for caching API responses to reduce API calls
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
  /// 
  /// If data is in cache and not expired, return cached data
  /// Otherwise, fetch data from API and cache it
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

  /// Get data from cache
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
      print('❌ Error getting data from cache: $e');
      return null;
    }
  }

  /// Fetch data from API and cache it
  Future<dynamic> _fetchAndCache(
    String key,
    Future<dynamic> Function() fetchFunction,
    int? cacheExpirationMinutes,
  ) async {
    try {
      // Fetch data from API
      final data = await fetchFunction();
      
      // Cache data
      await _cacheData(
        key,
        data,
        cacheExpirationMinutes ?? _defaultCacheExpirationMinutes,
      );
      
      return data;
    } catch (e) {
      print('❌ Error fetching and caching data: $e');
      rethrow;
    }
  }

  /// Cache data with expiration time
  Future<void> _cacheData(
    String key,
    dynamic data,
    int expirationMinutes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Calculate expiration time
      final expirationTime = DateTime.now().add(
        Duration(minutes: expirationMinutes),
      );
      
      // Create cache data
      final cacheMap = {
        'data': data,
        'expiration': expirationTime.toIso8601String(),
      };
      
      // Save to cache
      await prefs.setString(key, json.encode(cacheMap));
    } catch (e) {
      print('❌ Error caching data: $e');
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  /// Clear specific cache
  Future<void> clearCacheKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('❌ Error clearing cache key: $e');
    }
  }
}
