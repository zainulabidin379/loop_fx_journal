import '../datasources/hive_settings_datasource.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._datasource);

  final HiveSettingsDatasource _datasource;

  @override
  Future<void> clearSettings() => _datasource.clear();

  @override
  Future<AppSettings> getSettings() => _datasource.getSettings();

  @override
  Future<void> updateSettings(AppSettings settings) =>
      _datasource.saveSettings(settings);
}
