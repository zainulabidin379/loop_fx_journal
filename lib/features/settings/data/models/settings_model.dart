import 'package:hive/hive.dart';
import '../../domain/entities/app_settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  SettingsModel({
    required this.isBiometricEnabled,
    required this.baseCurrency,
    this.startingBalance,
    this.defaultRiskPercent,
    required this.themeMode,
    required this.isReminderEnabled,
  });

  @HiveField(0)
  bool isBiometricEnabled;

  @HiveField(1)
  String baseCurrency;

  @HiveField(2)
  double? startingBalance;

  @HiveField(3)
  double? defaultRiskPercent;

  @HiveField(4)
  String themeMode;

  @HiveField(5)
  bool isReminderEnabled;

  AppSettings toEntity() {
    return AppSettings(
      isBiometricEnabled: isBiometricEnabled,
      baseCurrency: baseCurrency,
      startingBalance: startingBalance,
      defaultRiskPercent: defaultRiskPercent,
      themeMode: themeMode,
      isReminderEnabled: isReminderEnabled,
    );
  }

  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      isBiometricEnabled: settings.isBiometricEnabled,
      baseCurrency: settings.baseCurrency,
      startingBalance: settings.startingBalance,
      defaultRiskPercent: settings.defaultRiskPercent,
      themeMode: settings.themeMode,
      isReminderEnabled: settings.isReminderEnabled,
    );
  }
}
