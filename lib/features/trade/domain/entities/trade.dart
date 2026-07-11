import 'package:equatable/equatable.dart';

enum TradeInstrument {
  xauusd,
  eurusd,
  gbpusd,
  usdjpy,
  gbpjpy,
  custom,
}

enum TradeDirection { long, short }

enum TradeOutcome { win, loss, breakeven, open }

enum EmotionBefore { calm, confident, anxious, fomo, revenge, tilted }

enum EmotionAfter { satisfied, regretful, neutral, frustrated }

extension TradeInstrumentX on TradeInstrument {
  String get label {
    switch (this) {
      case TradeInstrument.xauusd:
        return 'XAUUSD';
      case TradeInstrument.eurusd:
        return 'EURUSD';
      case TradeInstrument.gbpusd:
        return 'GBPUSD';
      case TradeInstrument.usdjpy:
        return 'USDJPY';
      case TradeInstrument.gbpjpy:
        return 'GBPJPY';
      case TradeInstrument.custom:
        return 'Custom';
    }
  }

  double get pipSize {
    switch (this) {
      case TradeInstrument.xauusd:
        return 0.1;
      case TradeInstrument.usdjpy:
      case TradeInstrument.gbpjpy:
        return 0.01;
      default:
        return 0.0001;
    }
  }
}

extension TradeDirectionX on TradeDirection {
  String get label => this == TradeDirection.long ? 'Long' : 'Short';
}

extension TradeOutcomeX on TradeOutcome {
  String get label {
    switch (this) {
      case TradeOutcome.win:
        return 'Win';
      case TradeOutcome.loss:
        return 'Loss';
      case TradeOutcome.breakeven:
        return 'Breakeven';
      case TradeOutcome.open:
        return 'Open';
    }
  }
}

extension EmotionBeforeX on EmotionBefore {
  String get label {
    switch (this) {
      case EmotionBefore.calm:
        return 'Calm';
      case EmotionBefore.confident:
        return 'Confident';
      case EmotionBefore.anxious:
        return 'Anxious';
      case EmotionBefore.fomo:
        return 'FOMO';
      case EmotionBefore.revenge:
        return 'Revenge';
      case EmotionBefore.tilted:
        return 'Tilted';
    }
  }
}

extension EmotionAfterX on EmotionAfter {
  String get label {
    switch (this) {
      case EmotionAfter.satisfied:
        return 'Satisfied';
      case EmotionAfter.regretful:
        return 'Regretful';
      case EmotionAfter.neutral:
        return 'Neutral';
      case EmotionAfter.frustrated:
        return 'Frustrated';
    }
  }
}

class Trade extends Equatable {
  const Trade({
    required this.id,
    required this.instrument,
    this.customInstrument,
    required this.direction,
    required this.entryPrice,
    this.exitPrice,
    required this.stopLoss,
    this.takeProfit,
    required this.lotSize,
    required this.entryDateTime,
    this.exitDateTime,
    required this.outcome,
    this.pnl,
    this.pnlPips,
    this.riskRewardPlanned,
    this.riskRewardActual,
    this.strategyId,
    this.notes,
    this.screenshotPaths,
    this.tags,
    this.emotionBefore,
    this.emotionAfter,
    this.accountBalanceAtEntry,
  });

  final String id;
  final TradeInstrument instrument;
  final String? customInstrument;
  final TradeDirection direction;
  final double entryPrice;
  final double? exitPrice;
  final double? stopLoss;
  final double? takeProfit;
  final double lotSize;
  final DateTime entryDateTime;
  final DateTime? exitDateTime;
  final TradeOutcome outcome;
  final double? pnl;
  final double? pnlPips;
  final double? riskRewardPlanned;
  final double? riskRewardActual;
  final String? strategyId;
  final String? notes;
  final List<String>? screenshotPaths;
  final List<String>? tags;
  final EmotionBefore? emotionBefore;
  final EmotionAfter? emotionAfter;
  final double? accountBalanceAtEntry;

  String get instrumentLabel =>
      instrument == TradeInstrument.custom ? (customInstrument ?? 'Custom') : instrument.label;

  bool get isOpen => outcome == TradeOutcome.open;

  Trade copyWith({
    String? id,
    TradeInstrument? instrument,
    String? customInstrument,
    TradeDirection? direction,
    double? entryPrice,
    double? exitPrice,
    double? stopLoss,
    double? takeProfit,
    double? lotSize,
    DateTime? entryDateTime,
    DateTime? exitDateTime,
    TradeOutcome? outcome,
    double? pnl,
    double? pnlPips,
    double? riskRewardPlanned,
    double? riskRewardActual,
    String? strategyId,
    String? notes,
    List<String>? screenshotPaths,
    List<String>? tags,
    EmotionBefore? emotionBefore,
    EmotionAfter? emotionAfter,
    double? accountBalanceAtEntry,
  }) {
    return Trade(
      id: id ?? this.id,
      instrument: instrument ?? this.instrument,
      customInstrument: customInstrument ?? this.customInstrument,
      direction: direction ?? this.direction,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      lotSize: lotSize ?? this.lotSize,
      entryDateTime: entryDateTime ?? this.entryDateTime,
      exitDateTime: exitDateTime ?? this.exitDateTime,
      outcome: outcome ?? this.outcome,
      pnl: pnl ?? this.pnl,
      pnlPips: pnlPips ?? this.pnlPips,
      riskRewardPlanned: riskRewardPlanned ?? this.riskRewardPlanned,
      riskRewardActual: riskRewardActual ?? this.riskRewardActual,
      strategyId: strategyId ?? this.strategyId,
      notes: notes ?? this.notes,
      screenshotPaths: screenshotPaths ?? this.screenshotPaths,
      tags: tags ?? this.tags,
      emotionBefore: emotionBefore ?? this.emotionBefore,
      emotionAfter: emotionAfter ?? this.emotionAfter,
      accountBalanceAtEntry: accountBalanceAtEntry ?? this.accountBalanceAtEntry,
    );
  }

  @override
  List<Object?> get props => [
        id,
        instrument,
        customInstrument,
        direction,
        entryPrice,
        exitPrice,
        stopLoss,
        takeProfit,
        lotSize,
        entryDateTime,
        exitDateTime,
        outcome,
        pnl,
        pnlPips,
        riskRewardPlanned,
        riskRewardActual,
        strategyId,
        notes,
        screenshotPaths,
        tags,
        emotionBefore,
        emotionAfter,
        accountBalanceAtEntry,
      ];
}
