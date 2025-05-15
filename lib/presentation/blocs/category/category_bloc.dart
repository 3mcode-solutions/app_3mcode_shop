import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/repositories/category_repository.dart';
import 'package:app_3mcode_shop/presentation/blocs/category/category_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
    on<SelectCategoryById>(_onSelectCategoryById);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());

    try {
      final categories = await _categoryRepository.getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategory event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;

      try {
        final selectedCategory = await _categoryRepository.getCategoryByName(
          event.categoryName,
        );

        if (selectedCategory != null) {
          emit(currentState.copyWith(selectedCategory: selectedCategory));
        }
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    }
  }

  Future<void> _onSelectCategoryById(
    SelectCategoryById event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;

      try {
        final selectedCategory = await _categoryRepository.getCategoryById(
          event.categoryId,
        );

        if (selectedCategory != null) {
          emit(currentState.copyWith(selectedCategory: selectedCategory));
        }
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    }
  }
}
