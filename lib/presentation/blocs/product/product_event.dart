import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all products
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Event to load featured products
class LoadFeaturedProducts extends ProductEvent {
  const LoadFeaturedProducts();
}

/// Event to search products by query
class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}

/// Event to load products by category
class LoadProductsByCategory extends ProductEvent {
  final String categoryName;

  const LoadProductsByCategory(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}
