import 'package:flutter_test/flutter_test.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';
import 'package:app_3mcode_shop/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late WooCommerceService wooCommerceService;

  setUpAll(() async {
    // Load environment variables from .env file
    await dotenv.load(fileName: '.env');
    wooCommerceService = WooCommerceService();
  });

  group('WooCommerce API Tests', () {
    test('should get products from WooCommerce API', () async {
      // Act
      final products = await wooCommerceService.getProducts();

      // Assert
      expect(products, isNotEmpty);
      expect(products.first, isNotNull);
    });

    test('should get product categories from WooCommerce API', () async {
      // Act
      final categories = await wooCommerceService.getCategories();

      // Assert
      expect(categories, isNotEmpty);
      expect(categories.first, isNotNull);
    });

    test('should search products by name', () async {
      // Arrange
      const searchQuery = 'bike';

      // Act
      final products = await wooCommerceService.getProducts(search: searchQuery);

      // Assert
      expect(products, isNotEmpty);
      expect(products.first, isNotNull);
    });

    test('should get product by ID', () async {
      // Arrange
      // First get a product ID from the list
      final products = await wooCommerceService.getProducts();
      final productId = (products.first as Map<String, dynamic>)['id'] as int;

      // Act
      final product = await wooCommerceService.getProduct(productId);

      // Assert
      expect(product, isNotNull);
      expect(product['id'], equals(productId));
    });
  });
}
