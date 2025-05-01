import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/product_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/product/product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  
  ProductBloc({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository,
       super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadFeaturedProducts>(_onLoadFeaturedProducts);
    on<SearchProducts>(_onSearchProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
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
      final searchResults = await _productRepository.searchProducts(event.query);
      emit(ProductSearchResultsLoaded(
        searchResults: searchResults,
        query: event.query,
      ));
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
      final products = await _productRepository.getProductsByCategory(event.categoryName);
      emit(ProductsByCategoryLoaded(
        products: products,
        categoryName: event.categoryName,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
