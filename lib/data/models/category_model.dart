import 'package:equatable/equatable.dart';

/// A model class representing a product category
class CategoryModel extends Equatable {
  final String name;
  final String image;

  CategoryModel({required this.name, required this.image})
    : assert(name.isNotEmpty, 'Category name cannot be empty'),
      assert(image.isNotEmpty, 'Category image path cannot be empty');

  @override
  List<Object> get props => [name, image];

  // Create a copy of this CategoryModel with the given fields replaced
  CategoryModel copyWith({String? name, String? image}) {
    return CategoryModel(name: name ?? this.name, image: image ?? this.image);
  }
}
