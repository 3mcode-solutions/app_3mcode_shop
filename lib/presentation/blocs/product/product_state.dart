import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

/// Initial state when no products have been loaded yet
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// State when products are being loaded
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// State when products have been loaded successfully
class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductLoaded(this.products);

  @override
  List<Object> get props => [products];
}

/// State when featured products have been loaded successfully
class FeaturedProductsLoaded extends ProductState {
  final List<ProductModel> featuredProducts;

  const FeaturedProductsLoaded(this.featuredProducts);

  @override
  List<Object> get props => [featuredProducts];
}

/// State when products by category have been loaded successfully
class ProductsByCategoryLoaded extends ProductState {
  final List<ProductModel> products;
  final String categoryName;

  const ProductsByCategoryLoaded({
    required this.products,
    required this.categoryName,
  });

  @override
  List<Object> get props => [products, categoryName];
}

/// State when search results have been loaded
class ProductSearchResultsLoaded extends ProductState {
  final List<ProductModel> searchResults;
  final String query;

  const ProductSearchResultsLoaded({
    required this.searchResults,
    required this.query,
  });

  @override
  List<Object> get props => [searchResults, query];
}

/// State when filter results have been loaded
class ProductFilterResultsLoaded extends ProductState {
  final List<ProductModel> filteredProducts;
  final Map<String, dynamic> filterParams;

  const ProductFilterResultsLoaded({
    required this.filteredProducts,
    required this.filterParams,
  });

  @override
  List<Object> get props => [filteredProducts, filterParams];
}

/// State when there was an error loading products
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
