part of 'splash_cubit.dart';

enum SplashStatus { initial, loading, ready }

class SplashState {
  const SplashState({
    this.status = SplashStatus.initial,
    this.biometricEnabled = false,
  });

  final SplashStatus status;
  final bool biometricEnabled;

  SplashState copyWith({
    SplashStatus? status,
    bool? biometricEnabled,
  }) {
    return SplashState(
      status: status ?? this.status,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
