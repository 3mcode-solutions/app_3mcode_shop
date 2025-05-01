import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

class SetDarkTheme extends ThemeEvent {
  const SetDarkTheme();
}

class SetLightTheme extends ThemeEvent {
  const SetLightTheme();
}
