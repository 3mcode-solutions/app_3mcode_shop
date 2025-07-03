import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoriteEvent {
  const LoadFavorites();
}

class AddToFavorites extends FavoriteEvent {
  final dynamic item;

  const AddToFavorites(this.item);

  @override
  List<Object> get props => [item is String ? item : item.id];

  String get itemId => item is String ? item : item.id;
}

class RemoveFromFavorites extends FavoriteEvent {
  final dynamic item;

  const RemoveFromFavorites(this.item);

  @override
  List<Object> get props => [item is String ? item : item.id];

  String get itemId => item is String ? item : item.id;
}

class ToggleFavorite extends FavoriteEvent {
  final dynamic item;

  const ToggleFavorite(this.item);

  @override
  List<Object> get props => [item is String ? item : item.id];

  String get itemId => item is String ? item : item.id;
}
