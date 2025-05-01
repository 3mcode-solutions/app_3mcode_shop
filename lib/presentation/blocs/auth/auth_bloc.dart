import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_3mcode_shop/data/models/user_model.dart';
import 'package:app_3mcode_shop/data/services/user_service.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_event.dart';
import 'package:app_3mcode_shop/presentation/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserService _userService = UserService();
  
  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<LogoutUser>(_onLogoutUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final isLoggedIn = await _userService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _userService.getCurrentUser();
        
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final success = await _userService.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
      );
      
      if (success) {
        final user = await _userService.getCurrentUser();
        
        if (user != null) {
          emit(RegistrationSuccess(user));
          emit(Authenticated(user));
        } else {
          emit(const RegistrationError('Failed to get user data after registration'));
        }
      } else {
        emit(const RegistrationError('Email already registered'));
      }
    } catch (e) {
      emit(RegistrationError(e.toString()));
    }
  }
  
  Future<void> _onLoginUser(
    LoginUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final success = await _userService.login(
        email: event.email,
        password: event.password,
      );
      
      if (success) {
        final user = await _userService.getCurrentUser();
        
        if (user != null) {
          emit(LoginSuccess(user));
          emit(Authenticated(user));
        } else {
          emit(const LoginError('Failed to get user data after login'));
        }
      } else {
        emit(const LoginError('Invalid email or password'));
      }
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
  
  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final success = await _userService.logout();
      
      if (success) {
        emit(const LogoutSuccess());
        emit(const Unauthenticated());
      } else {
        emit(const AuthError('Failed to logout'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final success = await _userService.updateProfile(
        name: event.name,
        phoneNumber: event.phoneNumber,
        photoUrl: event.photoUrl,
      );
      
      if (success) {
        final user = await _userService.getCurrentUser();
        
        if (user != null) {
          emit(ProfileUpdateSuccess(user));
          emit(Authenticated(user));
        } else {
          emit(const ProfileUpdateError('Failed to get user data after profile update'));
        }
      } else {
        emit(const ProfileUpdateError('Failed to update profile'));
      }
    } catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }
}
