import 'package:hive/hive.dart';
import '../../domain/entities/trade.dart';

part 'trade_model.g.dart';

@HiveType(typeId: 0)
class TradeModel extends HiveObject {
  TradeModel({
    required this.id,
    required this.instrumentIndex,
    this.customInstrument,
    required this.directionIndex,
    required this.entryPrice,
    this.exitPrice,
    this.stopLoss,
    this.takeProfit,
    required this.lotSize,
    required this.entryDateTime,
    this.exitDateTime,
    required this.outcomeIndex,
    this.pnl,
    this.pnlPips,
    this.riskRewardPlanned,
    this.riskRewardActual,
    this.strategyId,
    this.notes,
    this.screenshotPaths,
    this.tags,
    this.emotionBeforeIndex,
    this.emotionAfterIndex,
    this.accountBalanceAtEntry,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  int instrumentIndex;

  @HiveField(2)
  String? customInstrument;

  @HiveField(3)
  int directionIndex;

  @HiveField(4)
  double entryPrice;

  @HiveField(5)
  double? exitPrice;

  @HiveField(6)
  double? stopLoss;

  @HiveField(7)
  double? takeProfit;

  @HiveField(8)
  double lotSize;

  @HiveField(9)
  DateTime entryDateTime;

  @HiveField(10)
  DateTime? exitDateTime;

  @HiveField(11)
  int outcomeIndex;

  @HiveField(12)
  double? pnl;

  @HiveField(13)
  double? pnlPips;

  @HiveField(14)
  double? riskRewardPlanned;

  @HiveField(15)
  double? riskRewardActual;

  @HiveField(16)
  String? strategyId;

  @HiveField(17)
  String? notes;

  @HiveField(18)
  List<String>? screenshotPaths;

  @HiveField(19)
  List<String>? tags;

  @HiveField(20)
  int? emotionBeforeIndex;

  @HiveField(21)
  int? emotionAfterIndex;

  @HiveField(22)
  double? accountBalanceAtEntry;

  Trade toEntity() {
    return Trade(
      id: id,
      instrument: TradeInstrument.values[instrumentIndex],
      customInstrument: customInstrument,
      direction: TradeDirection.values[directionIndex],
      entryPrice: entryPrice,
      exitPrice: exitPrice,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      lotSize: lotSize,
      entryDateTime: entryDateTime,
      exitDateTime: exitDateTime,
      outcome: TradeOutcome.values[outcomeIndex],
      pnl: pnl,
      pnlPips: pnlPips,
      riskRewardPlanned: riskRewardPlanned,
      riskRewardActual: riskRewardActual,
      strategyId: strategyId,
      notes: notes,
      screenshotPaths: screenshotPaths,
      tags: tags,
      emotionBefore: emotionBeforeIndex != null
          ? EmotionBefore.values[emotionBeforeIndex!]
          : null,
      emotionAfter: emotionAfterIndex != null
          ? EmotionAfter.values[emotionAfterIndex!]
          : null,
      accountBalanceAtEntry: accountBalanceAtEntry,
    );
  }

  factory TradeModel.fromEntity(Trade trade) {
    return TradeModel(
      id: trade.id,
      instrumentIndex: trade.instrument.index,
      customInstrument: trade.customInstrument,
      directionIndex: trade.direction.index,
      entryPrice: trade.entryPrice,
      exitPrice: trade.exitPrice,
      stopLoss: trade.stopLoss,
      takeProfit: trade.takeProfit,
      lotSize: trade.lotSize,
      entryDateTime: trade.entryDateTime,
      exitDateTime: trade.exitDateTime,
      outcomeIndex: trade.outcome.index,
      pnl: trade.pnl,
      pnlPips: trade.pnlPips,
      riskRewardPlanned: trade.riskRewardPlanned,
      riskRewardActual: trade.riskRewardActual,
      strategyId: trade.strategyId,
      notes: trade.notes,
      screenshotPaths: trade.screenshotPaths,
      tags: trade.tags,
      emotionBeforeIndex: trade.emotionBefore?.index,
      emotionAfterIndex: trade.emotionAfter?.index,
      accountBalanceAtEntry: trade.accountBalanceAtEntry,
    );
  }
}
