import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all categories
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

/// Event to select a category by name
class SelectCategory extends CategoryEvent {
  final String categoryName;

  const SelectCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

/// Event to select a category by ID
class SelectCategoryById extends CategoryEvent {
  final String categoryId;

  const SelectCategoryById(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
