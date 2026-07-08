import '../datasources/local_auth_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._datasource);

  final LocalAuthDatasource _datasource;
  bool _isAuthenticated = false;

  @override
  Future<bool> authenticate() async {
    final result = await _datasource.authenticate();
    _isAuthenticated = result;
    return result;
  }

  @override
  Future<bool> checkBiometricAvailability() async {
    final supported = await _datasource.isDeviceSupported();
    if (!supported) return false;
    return _datasource.canCheckBiometrics();
  }

  @override
  bool isAuthenticated() => _isAuthenticated;

  @override
  void resetSession() {
    _isAuthenticated = false;
  }

  @override
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
  }
}
