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

  /// Get the Tutor LMS API consumer key
  static String get tutorLmsConsumerKey =>
      dotenv.env['TUTOR_LMS_CONSUMER_KEY'] ?? '';

  /// Get the Tutor LMS API consumer secret
  static String get tutorLmsConsumerSecret =>
      dotenv.env['TUTOR_LMS_CONSUMER_SECRET'] ?? '';

  /// Get the WordPress REST API base path
  static String get wpApiPath => '/wp-json';

  /// Get the Tutor LMS API path
  static String get tutorApiPath => '/tutor/v1';

  /// Get the WordPress API path
  static String get wpV2ApiPath => '/wp/v2';
}
