import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';
import '../../domain/entities/app_settings.dart';

class HiveSettingsDatasource {
  static const String boxName = 'settings';
  static const String settingsKey = 'app_settings';

  Box<SettingsModel>? _box;

  Future<Box<SettingsModel>> get box async {
    _box ??= await Hive.openBox<SettingsModel>(boxName);
    return _box!;
  }

  Future<AppSettings> getSettings() async {
    final settingsBox = await box;
    final model = settingsBox.get(settingsKey);
    return model?.toEntity() ?? AppSettings.defaults;
  }

  Future<void> saveSettings(AppSettings settings) async {
    final settingsBox = await box;
    await settingsBox.put(settingsKey, SettingsModel.fromEntity(settings));
  }

  Future<void> clear() async {
    final settingsBox = await box;
    await settingsBox.clear();
  }
}
