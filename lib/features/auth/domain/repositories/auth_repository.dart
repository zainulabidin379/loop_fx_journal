abstract class AuthRepository {
  Future<bool> authenticate();
  Future<bool> checkBiometricAvailability();
  bool isAuthenticated();
  void setAuthenticated(bool value);
  void resetSession();
}
