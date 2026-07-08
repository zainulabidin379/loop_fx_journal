import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../settings/domain/usecases/settings_usecases.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required this._getSettings, required this._resetAuthSession}) : super(const SplashState());

  final GetSettings _getSettings;
  final ResetAuthSession _resetAuthSession;

  Future<void> initialize() async {
    emit(state.copyWith(status: SplashStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    _resetAuthSession();
    final settings = await _getSettings(const NoParams());
    emit(state.copyWith(status: SplashStatus.ready, biometricEnabled: settings.isBiometricEnabled));
  }
}
