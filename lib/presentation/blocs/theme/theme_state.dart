import 'package:equatable/equatable.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
  
  @override
  List<Object> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  
  const ThemeLoaded(this.isDarkMode);
  
  @override
  List<Object> get props => [isDarkMode];
}

class ThemeError extends ThemeState {
  final String message;
  
  const ThemeError(this.message);
  
  @override
  List<Object> get props => [message];
}
