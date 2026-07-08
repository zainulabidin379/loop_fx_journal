part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthenticateRequested extends AuthEvent {
  const AuthenticateRequested();
}

class AuthSkipped extends AuthEvent {
  const AuthSkipped();
}
