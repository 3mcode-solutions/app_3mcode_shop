import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/theme/theme_manager.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeManager _themeManager = ThemeManager();
  
  ThemeBloc() : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetDarkTheme>(_onSetDarkTheme);
    on<SetLightTheme>(_onSetLightTheme);
  }
  
  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());
    try {
      final isDarkMode = await _themeManager.isDarkMode();
      emit(ThemeLoaded(isDarkMode));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
  
  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());
    try {
      final isDarkMode = await _themeManager.toggleTheme();
      emit(ThemeLoaded(isDarkMode));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
  
  Future<void> _onSetDarkTheme(
    SetDarkTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());
    try {
      await _themeManager.setDarkMode(true);
      emit(const ThemeLoaded(true));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
  
  Future<void> _onSetLightTheme(
    SetLightTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());
    try {
      await _themeManager.setDarkMode(false);
      emit(const ThemeLoaded(false));
    } catch (e) {
      emit(ThemeError(e.toString()));
    }
  }
}
