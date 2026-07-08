import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class Authenticate {
  Authenticate(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.authenticate();
}

class CheckBiometricAvailability implements UseCase<bool, NoParams> {
  CheckBiometricAvailability(this._repository);

  final AuthRepository _repository;

  @override
  Future<bool> call(NoParams params) => _repository.checkBiometricAvailability();
}

class IsAuthenticated {
  IsAuthenticated(this._repository);

  final AuthRepository _repository;

  bool call() => _repository.isAuthenticated();
}

class SetAuthenticated {
  SetAuthenticated(this._repository);

  final AuthRepository _repository;

  void call(bool value) => _repository.setAuthenticated(value);
}

class ResetAuthSession {
  ResetAuthSession(this._repository);

  final AuthRepository _repository;

  void call() => _repository.resetSession();
}
