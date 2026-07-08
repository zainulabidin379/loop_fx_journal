import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this._authenticate, required this._checkBiometricAvailability, required this._setAuthenticated})
    : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthenticateRequested>(_onAuthenticateRequested);
    on<AuthSkipped>(_onAuthSkipped);
  }

  final Authenticate _authenticate;
  final CheckBiometricAvailability _checkBiometricAvailability;
  final SetAuthenticated _setAuthenticated;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final available = await _checkBiometricAvailability(const NoParams());
    if (!available) {
      emit(const AuthUnavailable());
      return;
    }
    emit(const AuthReady());
  }

  Future<void> _onAuthenticateRequested(AuthenticateRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final success = await _authenticate();
    if (success) {
      _setAuthenticated(true);
      emit(const AuthSuccess());
    } else {
      emit(const AuthFailure());
    }
  }

  void _onAuthSkipped(AuthSkipped event, Emitter<AuthState> emit) {
    _setAuthenticated(true);
    emit(const AuthSuccess());
  }
}
