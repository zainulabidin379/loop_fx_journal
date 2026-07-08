part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardFilterChanged extends DashboardEvent {
  const DashboardFilterChanged({
    this.dateRange,
    this.instrument,
    this.strategyId,
    this.clearInstrument = false,
    this.clearStrategy = false,
  });

  final DateRangeFilter? dateRange;
  final TradeInstrument? instrument;
  final String? strategyId;
  final bool clearInstrument;
  final bool clearStrategy;

  @override
  List<Object?> get props =>
      [dateRange, instrument, strategyId, clearInstrument, clearStrategy];
}
