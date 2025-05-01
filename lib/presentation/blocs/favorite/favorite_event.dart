import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

class AddToFavorites extends FavoriteEvent {
  final String productId;

  const AddToFavorites(this.productId);

  @override
  List<Object> get props => [productId];
}

class RemoveFromFavorites extends FavoriteEvent {
  final String productId;

  const RemoveFromFavorites(this.productId);

  @override
  List<Object> get props => [productId];
}

class ToggleFavorite extends FavoriteEvent {
  final String productId;

  const ToggleFavorite(this.productId);

  @override
  List<Object> get props => [productId];
}
