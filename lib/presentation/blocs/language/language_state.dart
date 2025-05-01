import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();
  
  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();
}

class LanguageLoading extends LanguageState {
  const LanguageLoading();
}

class LanguageLoaded extends LanguageState {
  final Locale locale;
  
  const LanguageLoaded(this.locale);
  
  @override
  List<Object> get props => [locale];
}

class LanguageError extends LanguageState {
  final String message;
  
  const LanguageError(this.message);
  
  @override
  List<Object> get props => [message];
}
