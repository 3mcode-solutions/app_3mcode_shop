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

/// Event to select a category
class SelectCategory extends CategoryEvent {
  final String categoryName;

  const SelectCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}
