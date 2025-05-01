import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/services/favorite_service.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/favorite/favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteService _favoriteService = FavoriteService();
  
  FavoriteBloc() : super(const FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }
  
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(const FavoriteLoading());
    
    try {
      final favorites = await _favoriteService.getFavoriteProducts();
      final favoriteIds = await _favoriteService.getFavoriteIds();
      
      emit(FavoriteLoaded(
        favorites: favorites,
        favoriteIds: favoriteIds,
      ));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
  
  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      emit(const FavoriteLoading());
      
      try {
        final success = await _favoriteService.addToFavorites(event.productId);
        if (success) {
          final favorites = await _favoriteService.getFavoriteProducts();
          final favoriteIds = await _favoriteService.getFavoriteIds();
          
          emit(FavoriteLoaded(
            favorites: favorites,
            favoriteIds: favoriteIds,
          ));
        } else {
          emit(currentState);
        }
      } catch (e) {
        emit(FavoriteError(e.toString()));
      }
    }
  }
  
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoriteLoaded) {
      emit(const FavoriteLoading());
      
      try {
        final success = await _favoriteService.removeFromFavorites(event.productId);
        if (success) {
          final favorites = await _favoriteService.getFavoriteProducts();
          final favoriteIds = await _favoriteService.getFavoriteIds();
          
          emit(FavoriteLoaded(
            favorites: favorites,
            favoriteIds: favoriteIds,
          ));
        } else {
          emit(currentState);
        }
      } catch (e) {
        emit(FavoriteError(e.toString()));
      }
    }
  }
  
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final currentState = state;
    
    try {
      final isFavorite = await _favoriteService.isFavorite(event.productId);
      
      if (isFavorite) {
        add(RemoveFromFavorites(event.productId));
      } else {
        add(AddToFavorites(event.productId));
      }
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}
