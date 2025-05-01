import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  
  @override
  List<Object> get props => [];
}

/// Initial state when no categories have been loaded yet
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// State when categories are being loaded
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// State when categories have been loaded successfully
class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  
  const CategoryLoaded({
    required this.categories,
    this.selectedCategory,
  });
  
  @override
  List<Object> get props => [
    categories,
    if (selectedCategory != null) selectedCategory!,
  ];
  
  /// Create a copy of this state with a selected category
  CategoryLoaded copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

/// State when there was an error loading categories
class CategoryError extends CategoryState {
  final String message;
  
  const CategoryError(this.message);
  
  @override
  List<Object> get props => [message];
}
