import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/usecases/settings_usecases.dart';
import '../../../strategy/domain/entities/strategy.dart';
import '../../../strategy/domain/usecases/strategy_usecases.dart';
import '../../domain/entities/trade.dart';
import '../../domain/usecases/trade_usecases.dart';
import '../../domain/utils/trade_calculator.dart';

part 'trade_form_event.dart';
part 'trade_form_state.dart';

class TradeFormBloc extends Bloc<TradeFormEvent, TradeFormState> {
  TradeFormBloc({
    required this._addTrade,
    required this._updateTrade,
    required this._getTradeById,
    required this._getActiveStrategies,
    required this._getSettings,
  }) : super(const TradeFormState()) {
    on<TradeFormInit>(_onInit);
    on<TradeFormFieldChanged>(_onFieldChanged);
    on<TradeFormSaveRequested>(_onSave);
  }

  final AddTrade _addTrade;
  final UpdateTrade _updateTrade;
  final GetTradeById _getTradeById;
  final GetActiveStrategies _getActiveStrategies;
  final GetSettings _getSettings;
  final _uuid = const Uuid();

  Future<void> _onInit(TradeFormInit event, Emitter<TradeFormState> emit) async {
    emit(state.copyWith(status: TradeFormStatus.loading));
    final strategies = await _getActiveStrategies(const NoParams());
    final settings = await _getSettings(const NoParams());
    Trade? existing;
    if (event.tradeId != null) {
      existing = await _getTradeById(event.tradeId!);
    }
    emit(
      state.copyWith(
        status: TradeFormStatus.editing,
        tradeId: existing?.id,
        instrument: existing?.instrument ?? TradeInstrument.xauusd,
        customInstrument: existing?.customInstrument,
        direction: existing?.direction ?? TradeDirection.long,
        entryPrice: NumberFormatter.formatInput(existing?.entryPrice),
        exitPrice: NumberFormatter.formatInput(existing?.exitPrice),
        stopLoss: NumberFormatter.formatInput(existing?.stopLoss),
        takeProfit: NumberFormatter.formatInput(existing?.takeProfit),
        lotSize: NumberFormatter.formatInput(existing?.lotSize),
        entryDateTime: existing?.entryDateTime ?? DateTime.now(),
        exitDateTime: existing?.exitDateTime,
        strategyId: existing?.strategyId,
        notes: existing?.notes ?? '',
        tags: existing?.tags ?? [],
        screenshotPaths: existing?.screenshotPaths ?? [],
        emotionBefore: existing?.emotionBefore,
        emotionAfter: existing?.emotionAfter,
        isClosed: existing != null && existing.outcome != TradeOutcome.open,
        closePriceSource: _inferClosePriceSource(existing),
        strategies: strategies,
        settings: settings,
        plannedRR: existing?.riskRewardPlanned,
        suggestedLot: _computeSuggestedLot(
          settings: settings,
          entryPrice: existing?.entryPrice,
          stopLoss: existing?.stopLoss,
          instrument: existing?.instrument ?? TradeInstrument.xauusd,
        ),
      ),
    );
  }

  void _onFieldChanged(TradeFormFieldChanged event, Emitter<TradeFormState> emit) {
    final nextTakeProfit = event.takeProfit ?? state.takeProfit;
    final nextStopLoss = event.stopLoss ?? state.stopLoss;
    final nextClosePriceSource = event.closePriceSource ?? state.closePriceSource;
    var nextExitPrice = event.exitPrice ?? state.exitPrice;
    final nextIsClosed = event.isClosed ?? state.isClosed;

    if (nextIsClosed) {
      nextExitPrice = switch (nextClosePriceSource) {
        ClosePriceSource.takeProfit => nextTakeProfit,
        ClosePriceSource.stopLoss => nextStopLoss,
        ClosePriceSource.custom => nextExitPrice,
      };
      if (nextExitPrice.isNotEmpty) {
        nextExitPrice = NumberFormatter.formatString(nextExitPrice);
      }
    }

    final next = state.copyWith(
      instrument: event.instrument ?? state.instrument,
      customInstrument: event.customInstrument ?? state.customInstrument,
      direction: event.direction ?? state.direction,
      entryPrice: event.entryPrice ?? state.entryPrice,
      exitPrice: nextExitPrice,
      stopLoss: event.stopLoss ?? state.stopLoss,
      takeProfit: nextTakeProfit,
      lotSize: event.lotSize ?? state.lotSize,
      entryDateTime: event.entryDateTime ?? state.entryDateTime,
      exitDateTime: event.exitDateTime ?? state.exitDateTime,
      strategyId: event.strategyId ?? state.strategyId,
      notes: event.notes ?? state.notes,
      tags: event.tags ?? state.tags,
      screenshotPaths: event.screenshotPaths ?? state.screenshotPaths,
      emotionBefore: event.emotionBefore ?? state.emotionBefore,
      emotionAfter: event.emotionAfter ?? state.emotionAfter,
      isClosed: nextIsClosed,
      closePriceSource: nextClosePriceSource,
    );

    final entry = double.tryParse(next.entryPrice);
    final sl = double.tryParse(next.stopLoss);
    final tp = double.tryParse(next.takeProfit);

    emit(
      next.copyWith(
        clearValidationError: true,
        plannedRR: entry != null && sl != null
            ? TradeCalculator.plannedRiskReward(direction: next.direction, entryPrice: entry, stopLoss: sl, takeProfit: tp)
            : null,
        suggestedLot: _computeSuggestedLot(settings: next.settings, entryPrice: entry, stopLoss: sl, instrument: next.instrument),
      ),
    );
  }

  Future<void> _onSave(TradeFormSaveRequested event, Emitter<TradeFormState> emit) async {
    final validationError = _validateForm();
    if (validationError != null) {
      emit(state.copyWith(validationError: validationError));
      return;
    }

    emit(state.copyWith(status: TradeFormStatus.saving, clearValidationError: true));

    final entry = _parseRequired(state.entryPrice)!;
    final slParsed = _parseRequired(state.stopLoss);
    final lot = NumberFormatter.round(_parseRequired(state.lotSize)!);
    final tp = state.takeProfit.trim().isEmpty ? null : _parseRequired(state.takeProfit);
    final exitParsed = state.isClosed ? _parseRequired(_resolvedExitPrice()) : null;
    final exit = exitParsed;
    final isClosed = state.isClosed && exit != null;

    double? pnl;
    double? pnlPips;
    double? actualRR;
    TradeOutcome outcome = TradeOutcome.open;

    if (isClosed) {
      pnlPips = TradeCalculator.calculatePnlPips(
        instrument: state.instrument,
        direction: state.direction,
        entryPrice: entry,
        exitPrice: exit,
      );
      pnl = NumberFormatter.roundNullable((pnlPips ?? 0) * 10 * lot);
      if (slParsed != null && slParsed > 0) {
        actualRR = NumberFormatter.roundNullable(
          TradeCalculator.actualRiskReward(direction: state.direction, entryPrice: entry, stopLoss: slParsed, exitPrice: exit),
        );
      }
      pnlPips = NumberFormatter.roundNullable(pnlPips);
      outcome = TradeCalculator.outcomeFromPnl(pnl);
    }

    final trade = Trade(
      id: state.tradeId ?? _uuid.v4(),
      instrument: state.instrument,
      customInstrument: state.customInstrument,
      direction: state.direction,
      entryPrice: entry,
      exitPrice: exit,
      stopLoss: slParsed,
      takeProfit: tp,
      lotSize: lot,
      entryDateTime: state.entryDateTime ?? DateTime.now(),
      exitDateTime: isClosed ? (state.exitDateTime ?? DateTime.now()) : null,
      outcome: isClosed ? outcome : TradeOutcome.open,
      pnl: pnl,
      pnlPips: pnlPips,
      riskRewardPlanned: NumberFormatter.roundNullable(state.plannedRR),
      riskRewardActual: actualRR,
      strategyId: state.strategyId,
      notes: state.notes.isEmpty ? null : state.notes,
      screenshotPaths: state.screenshotPaths.isEmpty ? null : state.screenshotPaths,
      tags: state.tags.isEmpty ? null : state.tags,
      emotionBefore: state.emotionBefore,
      emotionAfter: state.emotionAfter,
      accountBalanceAtEntry: state.settings?.startingBalance,
    );

    try {
      if (state.tradeId != null) {
        await _updateTrade(trade);
      } else {
        await _addTrade(trade);
      }
      emit(state.copyWith(status: TradeFormStatus.saved));
    } catch (_) {
      emit(state.copyWith(status: TradeFormStatus.editing, validationError: AppStrings.error));
    }
  }

  double? _computeSuggestedLot({
    required AppSettings? settings,
    required double? entryPrice,
    required double? stopLoss,
    required TradeInstrument instrument,
  }) {
    if (settings?.startingBalance == null || settings?.defaultRiskPercent == null || entryPrice == null || stopLoss == null) {
      return null;
    }
    return TradeCalculator.suggestedLotSize(
      accountBalance: settings!.startingBalance!,
      riskPercent: settings.defaultRiskPercent!,
      entryPrice: entryPrice,
      stopLoss: stopLoss,
      instrument: instrument,
    );
  }

  ClosePriceSource _inferClosePriceSource(Trade? trade) {
    if (trade?.exitPrice == null) return ClosePriceSource.custom;
    if (trade!.takeProfit != null && trade.exitPrice == trade.takeProfit) {
      return ClosePriceSource.takeProfit;
    }
    if (trade.exitPrice == trade.stopLoss) {
      return ClosePriceSource.stopLoss;
    }
    return ClosePriceSource.custom;
  }

  double? _parseRequired(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  String _resolvedExitPrice() {
    return switch (state.closePriceSource) {
      ClosePriceSource.takeProfit => state.takeProfit,
      ClosePriceSource.stopLoss => state.stopLoss,
      ClosePriceSource.custom => state.exitPrice,
    };
  }

  String? _validateForm() {
    if (_parseRequired(state.entryPrice) == null) return '${AppStrings.entryPrice} is required';
    if (_parseRequired(state.lotSize) == null) return '${AppStrings.lotSize} is required';

    if (state.stopLoss.trim().isNotEmpty && _parseRequired(state.stopLoss) == null) {
      return '${AppStrings.stopLoss} must be a valid number';
    }

    if (state.takeProfit.trim().isNotEmpty && _parseRequired(state.takeProfit) == null) {
      return '${AppStrings.takeProfit} must be a valid number';
    }

    if (state.isClosed &&
        state.closePriceSource == ClosePriceSource.custom &&
        state.exitPrice.trim().isNotEmpty &&
        _parseRequired(state.exitPrice) == null) {
      return '${AppStrings.exitPrice} must be a valid number';
    }

    return null;
  }
}
