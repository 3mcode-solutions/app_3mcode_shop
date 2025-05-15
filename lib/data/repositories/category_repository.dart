import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/category_model.dart';
import 'package:app_3mcode_shop/data/models/woo_models/woo_product_model.dart';
import 'package:app_3mcode_shop/data/services/cache_service.dart';
import 'package:app_3mcode_shop/data/services/woocommerce_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CategoryRepository {
  // Singleton pattern
  static final CategoryRepository _instance = CategoryRepository._internal();

  factory CategoryRepository() {
    return _instance;
  }

  final WooCommerceService _wooCommerceService = WooCommerceService();
  final CacheService _cacheService = CacheService();
  final String _categoriesBoxName = 'categories';

  CategoryRepository._internal();

  /// Get all categories
  ///
  /// Fetches categories from WooCommerce API or local storage if offline
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    try {
      // Use cache service to get or fetch data
      final cacheKey = 'categories';

      return await _cacheService.getOrFetchData(
        cacheKey: cacheKey,
        forceRefresh: forceRefresh,
        fetchFunction: () async {
          // Fetch categories from WooCommerce API
          final wooCategories = await _wooCommerceService.getCategories(
            perPage: 50,
          );

          // Convert to app models
          final categories =
              wooCategories.map((category) {
                // Create CategoryModel from Map
                return CategoryModel.fromWooCategory(
                  WooProductCategory(
                    id: category['id'] as int,
                    name: category['name'] as String,
                    slug: category['slug'] as String?,
                    image:
                        category['image'] != null
                            ? (category['image'] as Map<String, dynamic>)['src']
                                as String?
                            : null,
                  ),
                );
              }).toList();

          // Save categories locally for offline use
          await _saveCategoriesLocally(categories);

          return categories;
        },
      );
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      // Fallback to local data in case of error
      return await _getLocalCategories();
    }
  }

  /// Get category by name
  ///
  /// Returns null if category not found
  Future<CategoryModel?> getCategoryByName(String name) async {
    final categories = await getCategories();

    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get category by ID
  ///
  /// Returns null if category not found
  Future<CategoryModel?> getCategoryById(String id) async {
    final categories = await getCategories();

    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save categories locally for offline use
  Future<void> _saveCategoriesLocally(List<CategoryModel> categories) async {
    try {
      final box = await Hive.openBox<Map>(_categoriesBoxName);

      // Clear existing data
      await box.clear();

      // Save new data
      for (final category in categories) {
        await box.add({
          'id': category.id,
          'name': category.name,
          'image': category.image,
        });
      }

      await box.close();
    } catch (e) {
      debugPrint('❌ Error saving categories locally: $e');
    }
  }

  /// Get categories from local storage
  Future<List<CategoryModel>> _getLocalCategories() async {
    try {
      final box = await Hive.openBox<Map>(_categoriesBoxName);

      if (box.isEmpty) {
        await box.close();
        return LocalData.getCategories();
      }

      // Convert maps to models
      final categories =
          box.values
              .map(
                (categoryMap) => CategoryModel(
                  id: categoryMap['id'] as String,
                  name: categoryMap['name'] as String,
                  image: categoryMap['image'] as String,
                ),
              )
              .toList();

      await box.close();
      return categories;
    } catch (e) {
      debugPrint('❌ Error getting categories from local storage: $e');
      return LocalData.getCategories();
    }
  }
}
