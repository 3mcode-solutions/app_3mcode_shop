import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:app_3mcode_shop/core/config/app_config.dart';

/// Service for interacting with the WooCommerce API
class WooCommerceService {
  // Singleton pattern
  static final WooCommerceService _instance = WooCommerceService._internal();

  factory WooCommerceService() {
    return _instance;
  }

  WooCommerceService._internal();

  /// Generate OAuth signature for WooCommerce API
  String _generateOAuthSignature(
    String url,
    String method,
    Map<String, String> parameters,
  ) {
    final consumerSecret = AppConfig.woocommerceConsumerSecret;

    // Sort parameters alphabetically
    final sortedParams = Map.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Create parameter string
    final paramString = sortedParams.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');

    // Create signature base string
    final baseString =
        '$method&${Uri.encodeComponent(url)}&${Uri.encodeComponent(paramString)}';

    // Generate HMAC-SHA1 signature
    final key = '$consumerSecret&';
    final hmacSha1 = Hmac(sha1, utf8.encode(key));
    final signature = hmacSha1.convert(utf8.encode(baseString));

    return base64.encode(signature.bytes);
  }

  /// Add authentication parameters to request
  Map<String, String> _addAuthParams(Map<String, String> params) {
    final consumerKey = AppConfig.woocommerceConsumerKey;

    params['consumer_key'] = consumerKey;
    params['consumer_secret'] = AppConfig.woocommerceConsumerSecret;

    return params;
  }

  /// Make a GET request to the WooCommerce API
  Future<dynamic> get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final params = queryParams ?? {};
    final authParams = _addAuthParams(params);

    final uri = Uri.parse(
      '${AppConfig.woocommerceApiUrl}/$endpoint',
    ).replace(queryParameters: authParams);

    print('🔗 Making GET request to: $uri');

    final response = await http.get(uri);

    print('📡 Response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = json.decode(response.body);
      print('✅ Response data received successfully');
      return data;
    } else {
      print('❌ API Error: ${response.statusCode} ${response.body}');
      throw Exception(
        'Failed to load data: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Make a POST request to the WooCommerce API
  Future<dynamic> post(String endpoint, dynamic data) async {
    final params = <String, String>{};
    final authParams = _addAuthParams(params);

    final uri = Uri.parse(
      '${AppConfig.woocommerceApiUrl}/$endpoint',
    ).replace(queryParameters: authParams);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to post data: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Make a PUT request to the WooCommerce API
  Future<dynamic> put(String endpoint, dynamic data) async {
    final params = <String, String>{};
    final authParams = _addAuthParams(params);

    final uri = Uri.parse(
      '${AppConfig.woocommerceApiUrl}/$endpoint',
    ).replace(queryParameters: authParams);

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to update data: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Make a DELETE request to the WooCommerce API
  Future<dynamic> delete(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final params = queryParams ?? {};
    final authParams = _addAuthParams(params);

    final uri = Uri.parse(
      '${AppConfig.woocommerceApiUrl}/$endpoint',
    ).replace(queryParameters: authParams);

    final response = await http.delete(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to delete data: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get all products
  Future<List<dynamic>> getProducts({
    int? page,
    int? perPage,
    String? category,
    String? categoryId,
    String? search,
  }) async {
    final queryParams = <String, String>{};

    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();
    if (category != null) queryParams['category'] = category;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (search != null) queryParams['search'] = search;

    final response = await get('products', queryParams);
    return response as List<dynamic>;
  }

  /// Get product by ID
  Future<dynamic> getProduct(int id) async {
    return await get('products/$id');
  }

  /// Get all product categories
  Future<List<dynamic>> getCategories({int? page, int? perPage}) async {
    final queryParams = <String, String>{};

    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final response = await get('products/categories', queryParams);
    return response as List<dynamic>;
  }

  /// Get cart contents
  Future<List<dynamic>> getCart() async {
    // Note: WooCommerce REST API doesn't have direct cart endpoints
    // This would typically require custom endpoints or session handling
    throw UnimplementedError(
      'Cart functionality requires custom implementation',
    );
  }

  /// Add product to cart
  Future<bool> addToCart(int productId, int quantity) async {
    // Note: WooCommerce REST API doesn't have direct cart endpoints
    // This would typically require custom endpoints or session handling
    throw UnimplementedError(
      'Cart functionality requires custom implementation',
    );
  }

  /// Update cart item quantity
  Future<bool> updateCartItemQuantity(String key, int quantity) async {
    // Note: WooCommerce REST API doesn't have direct cart endpoints
    // This would typically require custom endpoints or session handling
    throw UnimplementedError(
      'Cart functionality requires custom implementation',
    );
  }

  /// Remove item from cart
  Future<bool> removeCartItem(String key) async {
    // Note: WooCommerce REST API doesn't have direct cart endpoints
    // This would typically require custom endpoints or session handling
    throw UnimplementedError(
      'Cart functionality requires custom implementation',
    );
  }

  /// Get all coupons
  Future<List<dynamic>> getCoupons() async {
    final response = await get('coupons');
    return response as List<dynamic>;
  }

  /// Create order
  Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
    return await post('orders', orderData);
  }
}
