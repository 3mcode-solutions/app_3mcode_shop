import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/datasources/local/local_data.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorites';
  
  // الحصول على قائمة معرفات المنتجات المفضلة
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesList;
  }
  
  // الحصول على قائمة المنتجات المفضلة
  Future<List<ProductModel>> getFavoriteProducts() async {
    final favoriteIds = await getFavoriteIds();
    final allProducts = LocalData.getProducts();
    
    return allProducts.where((product) => favoriteIds.contains(product.id)).toList();
  }
  
  // التحقق مما إذا كان المنتج مفضلاً
  Future<bool> isFavorite(String productId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(productId);
  }
  
  // إضافة منتج إلى المفضلة
  Future<bool> addToFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    
    if (favoriteIds.contains(productId)) {
      return true; // المنتج موجود بالفعل في المفضلة
    }
    
    favoriteIds.add(productId);
    return await prefs.setStringList(_favoritesKey, favoriteIds);
  }
  
  // إزالة منتج من المفضلة
  Future<bool> removeFromFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();
    
    if (!favoriteIds.contains(productId)) {
      return true; // المنتج غير موجود في المفضلة
    }
    
    favoriteIds.remove(productId);
    return await prefs.setStringList(_favoritesKey, favoriteIds);
  }
  
  // تبديل حالة المفضلة (إضافة/إزالة)
  Future<bool> toggleFavorite(String productId) async {
    final isFav = await isFavorite(productId);
    if (isFav) {
      return await removeFromFavorites(productId);
    } else {
      return await addToFavorites(productId);
    }
  }
}
