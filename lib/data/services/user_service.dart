import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_3mcode_shop/data/models/user_model.dart';

class UserService {
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userDataKey = 'userData';
  static const String _usersKey = 'users';

  // Singleton instance
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  /// Check if a user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get the current logged in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (!(prefs.getBool(_isLoggedInKey) ?? false)) {
      return null;
    }

    final userData = prefs.getString(_userDataKey);
    if (userData == null) {
      return null;
    }

    try {
      return UserModel.fromJsonString(userData);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users =
        usersJson.map((json) => UserModel.fromJsonString(json)).toList();

    // Check if email already exists
    if (users.any((user) => user.email == email)) {
      return false; // Email already registered
    }

    // Create new user
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    // Add user to the list
    users.add(newUser);

    // Save updated users list
    await prefs.setStringList(
      _usersKey,
      users.map((user) => user.toJsonString()).toList(),
    );

    // Save user credentials (in a real app, you would hash the password)
    await prefs.setString('password_${newUser.email}', password);

    // Log in the user
    return await login(email: email, password: password);
  }

  /// Login a user
  Future<bool> login({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users =
        usersJson.map((json) => UserModel.fromJsonString(json)).toList();

    // Find user by email
    final userIndex = users.indexWhere((user) => user.email == email);
    if (userIndex == -1) {
      return false; // User not found
    }

    // Check password
    final savedPassword = prefs.getString('password_$email');
    if (savedPassword != password) {
      return false; // Incorrect password
    }

    // Update last login time
    final user = users[userIndex].copyWith(lastLoginAt: DateTime.now());
    users[userIndex] = user;

    // Save updated users list
    await prefs.setStringList(
      _usersKey,
      users.map((user) => user.toJsonString()).toList(),
    );

    // Save current user data
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userDataKey, user.toJsonString());

    return true;
  }

  /// Logout the current user
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userDataKey);

    return true;
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    // Update user data
    final updatedUser = currentUser.copyWith(
      name: name,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );

    // Get all users
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users =
        usersJson.map((json) => UserModel.fromJsonString(json)).toList();

    // Update user in the list
    final userIndex = users.indexWhere((user) => user.id == currentUser.id);
    if (userIndex != -1) {
      users[userIndex] = updatedUser;

      // Save updated users list
      await prefs.setStringList(
        _usersKey,
        users.map((user) => user.toJsonString()).toList(),
      );
    }

    // Save updated current user
    await prefs.setString(_userDataKey, updatedUser.toJsonString());

    return true;
  }

  /// Add a product to favorites
  Future<bool> addToFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    // Check if product is already in favorites
    if (currentUser.favoriteProductIds.contains(productId)) {
      return true; // Already in favorites
    }

    // Add product to favorites
    final favoriteProductIds = List<String>.from(currentUser.favoriteProductIds)
      ..add(productId);

    // Update user data
    final updatedUser = currentUser.copyWith(
      favoriteProductIds: favoriteProductIds,
    );

    // Get all users
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users =
        usersJson.map((json) => UserModel.fromJsonString(json)).toList();

    // Update user in the list
    final userIndex = users.indexWhere((user) => user.id == currentUser.id);
    if (userIndex != -1) {
      users[userIndex] = updatedUser;

      // Save updated users list
      await prefs.setStringList(
        _usersKey,
        users.map((user) => user.toJsonString()).toList(),
      );
    }

    // Save updated current user
    await prefs.setString(_userDataKey, updatedUser.toJsonString());

    return true;
  }

  /// Remove a product from favorites
  Future<bool> removeFromFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    // Get current user
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    // Check if product is in favorites
    if (!currentUser.favoriteProductIds.contains(productId)) {
      return true; // Not in favorites
    }

    // Remove product from favorites
    final favoriteProductIds = List<String>.from(currentUser.favoriteProductIds)
      ..remove(productId);

    // Update user data
    final updatedUser = currentUser.copyWith(
      favoriteProductIds: favoriteProductIds,
    );

    // Get all users
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    final users =
        usersJson.map((json) => UserModel.fromJsonString(json)).toList();

    // Update user in the list
    final userIndex = users.indexWhere((user) => user.id == currentUser.id);
    if (userIndex != -1) {
      users[userIndex] = updatedUser;

      // Save updated users list
      await prefs.setStringList(
        _usersKey,
        users.map((user) => user.toJsonString()).toList(),
      );
    }

    // Save updated current user
    await prefs.setString(_userDataKey, updatedUser.toJsonString());

    return true;
  }

  /// Check if a product is in favorites
  Future<bool> isFavorite(String productId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return false;
    }

    return currentUser.favoriteProductIds.contains(productId);
  }

  /// Get all favorite products
  Future<List<String>> getFavorites() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      return [];
    }

    return currentUser.favoriteProductIds;
  }
}
