import 'package:app_3mcode_shop/core/constants/app_constants.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';
import 'package:app_3mcode_shop/data/models/category_model.dart';

class CategoryRepository {
  // Singleton pattern
  static final CategoryRepository _instance = CategoryRepository._internal();
  
  factory CategoryRepository() {
    return _instance;
  }
  
  CategoryRepository._internal();
  
  /// Get all categories
  /// 
  /// This method simulates an API call by adding a delay
  Future<List<CategoryModel>> getCategories() async {
    // Simulate network delay
    await Future.delayed(AppConstants.mockNetworkDelay);
    
    return LocalData.getCategories();
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
}
