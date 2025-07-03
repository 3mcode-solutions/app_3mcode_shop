import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/product_model.dart';
import 'package:app_3mcode_shop/data/models/course_model.dart';

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
  final List<dynamic> items;
  final List<String> favoriteIds;

  const FavoriteLoaded({required this.items, required this.favoriteIds});

  @override
  List<Object> get props => [items, favoriteIds];

  bool isFavorite(String itemId) => favoriteIds.contains(itemId);

  List<ProductModel> get favorites => items.whereType<ProductModel>().toList();

  List<CourseModel> get courses => items.whereType<CourseModel>().toList();

  FavoriteLoaded copyWith({List<dynamic>? items, List<String>? favoriteIds}) {
    return FavoriteLoaded(
      items: items ?? this.items,
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
