// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      isBiometricEnabled: fields[0] as bool,
      baseCurrency: fields[1] as String,
      startingBalance: fields[2] as double?,
      defaultRiskPercent: fields[3] as double?,
      themeMode: fields[4] as String,
      isReminderEnabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isBiometricEnabled)
      ..writeByte(1)
      ..write(obj.baseCurrency)
      ..writeByte(2)
      ..write(obj.startingBalance)
      ..writeByte(3)
      ..write(obj.defaultRiskPercent)
      ..writeByte(4)
      ..write(obj.themeMode)
      ..writeByte(5)
      ..write(obj.isReminderEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
