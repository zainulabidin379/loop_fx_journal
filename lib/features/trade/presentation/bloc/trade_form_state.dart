part of 'trade_form_bloc.dart';

enum TradeFormStatus { initial, loading, editing, saving, saved, error }

class TradeFormState extends Equatable {
  const TradeFormState({
    this.status = TradeFormStatus.initial,
    this.tradeId,
    this.instrument = TradeInstrument.xauusd,
    this.customInstrument,
    this.direction = TradeDirection.long,
    this.entryPrice = '',
    this.exitPrice = '',
    this.stopLoss = '',
    this.takeProfit = '',
    this.lotSize = '',
    this.entryDateTime,
    this.exitDateTime,
    this.strategyId,
    this.notes = '',
    this.tags = const [],
    this.screenshotPaths = const [],
    this.emotionBefore,
    this.emotionAfter,
    this.isClosed = false,
    this.strategies = const [],
    this.settings,
    this.plannedRR,
    this.suggestedLot,
  });

  final TradeFormStatus status;
  final String? tradeId;
  final TradeInstrument instrument;
  final String? customInstrument;
  final TradeDirection direction;
  final String entryPrice;
  final String exitPrice;
  final String stopLoss;
  final String takeProfit;
  final String lotSize;
  final DateTime? entryDateTime;
  final DateTime? exitDateTime;
  final String? strategyId;
  final String notes;
  final List<String> tags;
  final List<String> screenshotPaths;
  final EmotionBefore? emotionBefore;
  final EmotionAfter? emotionAfter;
  final bool isClosed;
  final List<Strategy> strategies;
  final AppSettings? settings;
  final double? plannedRR;
  final double? suggestedLot;

  TradeFormState copyWith({
    TradeFormStatus? status,
    String? tradeId,
    TradeInstrument? instrument,
    String? customInstrument,
    TradeDirection? direction,
    String? entryPrice,
    String? exitPrice,
    String? stopLoss,
    String? takeProfit,
    String? lotSize,
    DateTime? entryDateTime,
    DateTime? exitDateTime,
    String? strategyId,
    String? notes,
    List<String>? tags,
    List<String>? screenshotPaths,
    EmotionBefore? emotionBefore,
    EmotionAfter? emotionAfter,
    bool? isClosed,
    List<Strategy>? strategies,
    AppSettings? settings,
    double? plannedRR,
    double? suggestedLot,
  }) {
    return TradeFormState(
      status: status ?? this.status,
      tradeId: tradeId ?? this.tradeId,
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
      strategyId: strategyId ?? this.strategyId,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      screenshotPaths: screenshotPaths ?? this.screenshotPaths,
      emotionBefore: emotionBefore ?? this.emotionBefore,
      emotionAfter: emotionAfter ?? this.emotionAfter,
      isClosed: isClosed ?? this.isClosed,
      strategies: strategies ?? this.strategies,
      settings: settings ?? this.settings,
      plannedRR: plannedRR ?? this.plannedRR,
      suggestedLot: suggestedLot ?? this.suggestedLot,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tradeId,
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
        strategyId,
        notes,
        tags,
        screenshotPaths,
        emotionBefore,
        emotionAfter,
        isClosed,
        strategies,
        settings,
        plannedRR,
        suggestedLot,
      ];
}
