import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for the application
/// 
/// This class provides access to environment variables and other configuration settings
class AppConfig {
  /// Load environment variables from .env file
  static Future<void> load() async {
    await dotenv.load();
  }
  
  /// Get the WooCommerce API URL
  static String get woocommerceUrl => 
      dotenv.env['WOOCOMMERCE_URL'] ?? 'https://shop.3mcode-solutions.com';
      
  /// Get the WooCommerce API consumer key
  static String get woocommerceConsumerKey => 
      dotenv.env['WOOCOMMERCE_CONSUMER_KEY'] ?? '';
      
  /// Get the WooCommerce API consumer secret
  static String get woocommerceConsumerSecret => 
      dotenv.env['WOOCOMMERCE_CONSUMER_SECRET'] ?? '';
      
  /// Get the WooCommerce API version
  static String get woocommerceApiVersion => 'wc/v3';
  
  /// Get the full WooCommerce API base URL
  static String get woocommerceApiUrl => 
      '$woocommerceUrl/wp-json/$woocommerceApiVersion';
}
