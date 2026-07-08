import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.isBiometricEnabled,
    required this.baseCurrency,
    this.startingBalance,
    this.defaultRiskPercent,
    required this.themeMode,
    required this.isReminderEnabled,
  });

  final bool isBiometricEnabled;
  final String baseCurrency;
  final double? startingBalance;
  final double? defaultRiskPercent;
  final String themeMode;
  final bool isReminderEnabled;

  static const AppSettings defaults = AppSettings(
    isBiometricEnabled: false,
    baseCurrency: 'USD',
    startingBalance: null,
    defaultRiskPercent: 1.0,
    themeMode: 'dark',
    isReminderEnabled: false,
  );

  AppSettings copyWith({
    bool? isBiometricEnabled,
    String? baseCurrency,
    double? startingBalance,
    double? defaultRiskPercent,
    String? themeMode,
    bool? isReminderEnabled,
  }) {
    return AppSettings(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      startingBalance: startingBalance ?? this.startingBalance,
      defaultRiskPercent: defaultRiskPercent ?? this.defaultRiskPercent,
      themeMode: themeMode ?? this.themeMode,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
        isBiometricEnabled,
        baseCurrency,
        startingBalance,
        defaultRiskPercent,
        themeMode,
        isReminderEnabled,
      ];
}
