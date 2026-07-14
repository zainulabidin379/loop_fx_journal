// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeModelAdapter extends TypeAdapter<TradeModel> {
  @override
  final int typeId = 0;

  @override
  TradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradeModel(
      id: fields[0] as String,
      instrumentIndex: fields[1] as int,
      customInstrument: fields[2] as String?,
      directionIndex: fields[3] as int,
      entryPrice: fields[4] as double,
      exitPrice: fields[5] as double?,
      stopLoss: fields[6] as double?,
      takeProfit: fields[7] as double?,
      lotSize: fields[8] as double,
      entryDateTime: fields[9] as DateTime,
      exitDateTime: fields[10] as DateTime?,
      outcomeIndex: fields[11] as int,
      pnl: fields[12] as double?,
      pnlPips: fields[13] as double?,
      riskRewardPlanned: fields[14] as double?,
      riskRewardActual: fields[15] as double?,
      strategyId: fields[16] as String?,
      notes: fields[17] as String?,
      screenshotPaths: (fields[18] as List?)?.cast<String>(),
      tags: (fields[19] as List?)?.cast<String>(),
      emotionBeforeIndex: fields[20] as int?,
      emotionAfterIndex: fields[21] as int?,
      accountBalanceAtEntry: fields[22] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TradeModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.instrumentIndex)
      ..writeByte(2)
      ..write(obj.customInstrument)
      ..writeByte(3)
      ..write(obj.directionIndex)
      ..writeByte(4)
      ..write(obj.entryPrice)
      ..writeByte(5)
      ..write(obj.exitPrice)
      ..writeByte(6)
      ..write(obj.stopLoss)
      ..writeByte(7)
      ..write(obj.takeProfit)
      ..writeByte(8)
      ..write(obj.lotSize)
      ..writeByte(9)
      ..write(obj.entryDateTime)
      ..writeByte(10)
      ..write(obj.exitDateTime)
      ..writeByte(11)
      ..write(obj.outcomeIndex)
      ..writeByte(12)
      ..write(obj.pnl)
      ..writeByte(13)
      ..write(obj.pnlPips)
      ..writeByte(14)
      ..write(obj.riskRewardPlanned)
      ..writeByte(15)
      ..write(obj.riskRewardActual)
      ..writeByte(16)
      ..write(obj.strategyId)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.screenshotPaths)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.emotionBeforeIndex)
      ..writeByte(21)
      ..write(obj.emotionAfterIndex)
      ..writeByte(22)
      ..write(obj.accountBalanceAtEntry);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
