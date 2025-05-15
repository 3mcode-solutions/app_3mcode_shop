import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/product_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
    : _productRepository = productRepository,
      super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadFeaturedProducts>(_onLoadFeaturedProducts);
    on<SearchProducts>(_onSearchProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<LoadProductsByCategoryId>(_onLoadProductsByCategoryId);
    on<FilterProducts>(_onFilterProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final products = await _productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadFeaturedProducts(
    LoadFeaturedProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final featuredProducts = await _productRepository.getFeaturedProducts();
      emit(FeaturedProductsLoaded(featuredProducts));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final searchResults = await _productRepository.searchProducts(
        event.query,
      );
      emit(
        ProductSearchResultsLoaded(
          searchResults: searchResults,
          query: event.query,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final products = await _productRepository.getProductsByCategory(
        event.categoryName,
      );
      emit(
        ProductsByCategoryLoaded(
          products: products,
          categoryName: event.categoryName,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategoryId(
    LoadProductsByCategoryId event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final products = await _productRepository.getProductsByCategoryId(
        event.categoryId,
      );
      emit(
        ProductsByCategoryLoaded(
          products: products,
          categoryId: event.categoryId,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilterProducts(
    FilterProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    try {
      final allProducts = await _productRepository.getProducts();

      // Apply filters
      final filteredProducts =
          allProducts.where((product) {
            // Price filter
            final minPrice = event.filterParams['min_price'] as double;
            final maxPrice = event.filterParams['max_price'] as double;
            final productPrice = product.priceAsDouble;

            if (productPrice < minPrice || productPrice > maxPrice) {
              return false;
            }

            // Rating filter
            final minRating = event.filterParams['min_rating'] as double;
            final productRating = product.rateAsDouble;

            if (productRating < minRating) {
              return false;
            }

            // Category filter
            final category = event.filterParams['category'] as String;
            if (category.isNotEmpty) {
              // This is a simplified approach. In a real app, you would have a category field in the product model
              if (!product.name.toLowerCase().contains(
                category.toLowerCase(),
              )) {
                return false;
              }
            }

            // Discounted filter
            final onlyDiscounted =
                event.filterParams['only_discounted'] as bool;
            if (onlyDiscounted && !product.isOnSale) {
              return false;
            }

            return true;
          }).toList();

      emit(
        ProductFilterResultsLoaded(
          filteredProducts: filteredProducts,
          filterParams: event.filterParams,
        ),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
