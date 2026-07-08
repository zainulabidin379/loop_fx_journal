import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings implements UseCase<AppSettings, NoParams> {
  GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(NoParams params) => _repository.getSettings();
}

class UpdateSettings implements UseCase<void, AppSettings> {
  UpdateSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<void> call(AppSettings params) => _repository.updateSettings(params);
}
