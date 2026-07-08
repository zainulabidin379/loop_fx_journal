part of 'trade_form_bloc.dart';

sealed class TradeFormEvent extends Equatable {
  const TradeFormEvent();

  @override
  List<Object?> get props => [];
}

class TradeFormInit extends TradeFormEvent {
  const TradeFormInit({this.tradeId});

  final String? tradeId;

  @override
  List<Object?> get props => [tradeId];
}

class TradeFormFieldChanged extends TradeFormEvent {
  const TradeFormFieldChanged({
    this.instrument,
    this.customInstrument,
    this.direction,
    this.entryPrice,
    this.exitPrice,
    this.stopLoss,
    this.takeProfit,
    this.lotSize,
    this.entryDateTime,
    this.exitDateTime,
    this.strategyId,
    this.notes,
    this.tags,
    this.screenshotPaths,
    this.emotionBefore,
    this.emotionAfter,
    this.isClosed,
    this.closePriceSource,
  });

  final TradeInstrument? instrument;
  final String? customInstrument;
  final TradeDirection? direction;
  final String? entryPrice;
  final String? exitPrice;
  final String? stopLoss;
  final String? takeProfit;
  final String? lotSize;
  final DateTime? entryDateTime;
  final DateTime? exitDateTime;
  final String? strategyId;
  final String? notes;
  final List<String>? tags;
  final List<String>? screenshotPaths;
  final EmotionBefore? emotionBefore;
  final EmotionAfter? emotionAfter;
  final bool? isClosed;
  final ClosePriceSource? closePriceSource;

  @override
  List<Object?> get props => [
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
        closePriceSource,
      ];
}

class TradeFormSaveRequested extends TradeFormEvent {
  const TradeFormSaveRequested();
}
