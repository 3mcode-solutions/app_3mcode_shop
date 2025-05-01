import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

abstract class FavoriteState extends Equatable {
  const FavoriteState();
  
  @override
  List<Object> get props => [];
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final List<ProductModel> favorites;
  final List<String> favoriteIds;
  
  const FavoriteLoaded({
    required this.favorites,
    required this.favoriteIds,
  });
  
  @override
  List<Object> get props => [favorites, favoriteIds];
  
  bool isFavorite(String productId) => favoriteIds.contains(productId);
  
  FavoriteLoaded copyWith({
    List<ProductModel>? favorites,
    List<String>? favoriteIds,
  }) {
    return FavoriteLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

class FavoriteError extends FavoriteState {
  final String message;
  
  const FavoriteError(this.message);
  
  @override
  List<Object> get props => [message];
}
