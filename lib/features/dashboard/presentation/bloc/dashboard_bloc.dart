import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../strategy/domain/usecases/strategy_usecases.dart';
import '../../../trade/domain/entities/trade.dart';
import '../../../trade/domain/usecases/trade_usecases.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/utils/dashboard_analytics.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required this._getTrades, required this._getOpenTrades, required this._getStrategies}) : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardFilterChanged>(_onFilterChanged);
  }

  final GetTrades _getTrades;
  final GetOpenTrades _getOpenTrades;
  final GetStrategies _getStrategies;

  Future<void> _onLoad(DashboardLoadRequested event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final allTrades = await _getTrades(const NoParams());
      final openTrades = await _getOpenTrades(const NoParams());
      final strategies = await _getStrategies(const NoParams());
      final strategyNames = {for (final s in strategies) s.id: s.name};
      final filtered = DashboardAnalytics.filterTrades(allTrades, state.filter);

      emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          allTrades: allTrades,
          filteredTrades: filtered,
          openTrades: openTrades,
          strategyNames: strategyNames,
          metrics: DashboardAnalytics.computeMetrics(filtered),
          equityCurve: DashboardAnalytics.computeEquityCurve(filtered),
          winLoss: DashboardAnalytics.winLossBreakdown(filtered),
          byInstrument: DashboardAnalytics.byInstrument(filtered),
          byStrategy: DashboardAnalytics.byStrategy(filtered, strategyNames),
          byEmotion: DashboardAnalytics.byEmotion(filtered),
          bestTrade: DashboardAnalytics.bestTrade(filtered),
          worstTrade: DashboardAnalytics.worstTrade(filtered),
          streak: DashboardAnalytics.computeStreak(filtered),
          weeklyRecap: DashboardAnalytics.weeklyRecap(allTrades),
          monthlyRecap: DashboardAnalytics.monthlyRecap(allTrades),
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: DashboardStatus.error));
    }
  }

  void _onFilterChanged(DashboardFilterChanged event, Emitter<DashboardState> emit) {
    final filter = state.filter.copyWith(
      dateRange: event.dateRange,
      instrument: event.instrument,
      strategyId: event.strategyId,
      clearInstrument: event.clearInstrument,
      clearStrategy: event.clearStrategy,
    );
    final filtered = DashboardAnalytics.filterTrades(state.allTrades, filter);
    emit(
      state.copyWith(
        filter: filter,
        filteredTrades: filtered,
        metrics: DashboardAnalytics.computeMetrics(filtered),
        equityCurve: DashboardAnalytics.computeEquityCurve(filtered),
        winLoss: DashboardAnalytics.winLossBreakdown(filtered),
        byInstrument: DashboardAnalytics.byInstrument(filtered),
        byStrategy: DashboardAnalytics.byStrategy(filtered, state.strategyNames),
        byEmotion: DashboardAnalytics.byEmotion(filtered),
        bestTrade: DashboardAnalytics.bestTrade(filtered),
        worstTrade: DashboardAnalytics.worstTrade(filtered),
        streak: DashboardAnalytics.computeStreak(filtered),
      ),
    );
  }
}
