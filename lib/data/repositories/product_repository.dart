import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

class ProductRepository {
  // Singleton pattern
  static final ProductRepository _instance = ProductRepository._internal();
  
  factory ProductRepository() {
    return _instance;
  }
  
  ProductRepository._internal();
  
  /// Get all products
  /// 
  /// This method simulates an API call by adding a delay
  Future<List<ProductModel>> getProducts() async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);
    
    return LocalData.getProducts();
  }
  
  /// Get product by name
  /// 
  /// Returns null if product not found
  Future<ProductModel?> getProductByName(String name) async {
    final products = await getProducts();
    
    try {
      return products.firstWhere(
        (product) => product.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Search products by name
  /// 
  /// Returns empty list if no products found
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
  
  /// Get featured products
  /// 
  /// Returns a subset of products for featured section
  Future<List<ProductModel>> getFeaturedProducts() async {
    final products = await getProducts();
    
    // For demo purposes, just return the first 5 products
    return products.take(5).toList();
  }
  
  /// Get products by category
  /// 
  /// Returns products that belong to the specified category
  /// For demo purposes, we're just returning all products since we don't have category assignments
  Future<List<ProductModel>> getProductsByCategory(String categoryName) async {
    // In a real app, we would filter products by category
    // For now, just return all products with a delay
    await Future.delayed(AppConstants.mockNetworkDelay);
    
    return LocalData.getProducts();
  }
}
