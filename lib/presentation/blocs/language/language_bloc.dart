import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/core/localization/language_manager.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/language/language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageManager _languageManager = LanguageManager();
  
  LanguageBloc() : super(const LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }
  
  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(const LanguageLoading());
    try {
      final locale = await _languageManager.getLocale();
      emit(LanguageLoaded(locale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
  
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(const LanguageLoading());
    try {
      await _languageManager.setLocale(event.locale);
      emit(LanguageLoaded(event.locale));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
}
