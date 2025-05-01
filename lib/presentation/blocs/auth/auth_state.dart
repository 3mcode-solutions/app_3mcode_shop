import 'package:equatable/equatable.dart';
import 'package:app_3mcode_shop/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class Authenticated extends AuthState {
  final UserModel user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication error state
class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Registration success state
class RegistrationSuccess extends AuthState {
  final UserModel user;
  
  const RegistrationSuccess(this.user);
  
  @override
  List<Object> get props => [user];
}

/// Registration error state
class RegistrationError extends AuthState {
  final String message;
  
  const RegistrationError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Login success state
class LoginSuccess extends AuthState {
  final UserModel user;
  
  const LoginSuccess(this.user);
  
  @override
  List<Object> get props => [user];
}

/// Login error state
class LoginError extends AuthState {
  final String message;
  
  const LoginError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Logout success state
class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

/// Profile update success state
class ProfileUpdateSuccess extends AuthState {
  final UserModel user;
  
  const ProfileUpdateSuccess(this.user);
  
  @override
  List<Object> get props => [user];
}

/// Profile update error state
class ProfileUpdateError extends AuthState {
  final String message;
  
  const ProfileUpdateError(this.message);
  
  @override
  List<Object> get props => [message];
}
