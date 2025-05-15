import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/woo_models/woo_product_model.dart';

/// A model class representing a product category
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String image;

  CategoryModel({required this.id, required this.name, required this.image})
    : assert(name.isNotEmpty, 'Category name cannot be empty'),
      assert(image.isNotEmpty, 'Category image path cannot be empty');

  @override
  List<Object> get props => [id, name, image];

  // Create a copy of this CategoryModel with the given fields replaced
  CategoryModel copyWith({String? id, String? name, String? image}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }

  /// Create a CategoryModel from a WooProductCategory
  factory CategoryModel.fromWooCategory(WooProductCategory category) {
    // Use a default image if none is provided
    String imageUrl = category.image ?? '';

    // If no image is provided, use a default image based on category name
    if (imageUrl.isEmpty) {
      // Try to find a matching default image based on category name
      final categoryName = category.name.toLowerCase();
      if (categoryName.contains('fruit')) {
        imageUrl = 'assets/category/fruits.png';
      } else if (categoryName.contains('vegetable')) {
        imageUrl = 'assets/category/vegatbels.png';
      } else if (categoryName.contains('milk') ||
          categoryName.contains('dairy')) {
        imageUrl = 'assets/category/egg.png';
      } else if (categoryName.contains('beverage') ||
          categoryName.contains('drink')) {
        imageUrl = 'assets/category/beverages.png';
      } else if (categoryName.contains('laundry') ||
          categoryName.contains('clean')) {
        imageUrl = 'assets/category/laundry.png';
      } else {
        // Default image if no match is found
        imageUrl = 'assets/category/fruits.png';
      }
    }

    return CategoryModel(
      id: category.id.toString(),
      name: category.name,
      image: imageUrl,
    );
  }
}
