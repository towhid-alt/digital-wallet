part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email, password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String username, email, password;

  const SignUpRequested({required this.username, required this.email, required this.password});

  @override
  List<Object> get props => [username, email, password];
}