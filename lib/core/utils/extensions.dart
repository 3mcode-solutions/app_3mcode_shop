import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Screen size helpers
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  // Navigation helpers
  void pop<T>([T? result]) => Navigator.of(this).pop<T>(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );
  Future<T?> pushReplacement<T, TO>(Widget page) => 
      Navigator.of(this).pushReplacement<T, TO>(
        MaterialPageRoute(builder: (_) => page),
      );
}

extension StringExtensions on String {
  // Capitalize first letter of each word
  String get capitalizeFirstOfEach => split(' ')
      .map((str) => str.isNotEmpty 
          ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
          : '')
      .join(' ');
      
  // Check if string is a valid price
  bool get isValidPrice => double.tryParse(this) != null;
}

extension DoubleExtensions on double {
  // Format price with 2 decimal places
  String get toPrice => toStringAsFixed(2);
}
