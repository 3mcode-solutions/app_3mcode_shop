import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if a user is logged in
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to register a new user
class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;

  const RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, password, phoneNumber];
}

/// Event to login a user
class LoginUser extends AuthEvent {
  final String email;
  final String password;

  const LoginUser({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event to logout a user
class LogoutUser extends AuthEvent {
  const LogoutUser();
}

/// Event to update user profile
class UpdateUserProfile extends AuthEvent {
  final String name;
  final String? phoneNumber;
  final String? photoUrl;

  const UpdateUserProfile({
    required this.name,
    this.phoneNumber,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, phoneNumber, photoUrl];
}
