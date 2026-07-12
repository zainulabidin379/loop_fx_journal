import 'package:equatable/equatable.dart';
import '../../../trade/domain/entities/trade.dart';

enum DateRangeFilter { d7, d30, d90, all, custom }

class DashboardFilter extends Equatable {
  const DashboardFilter({
    this.dateRange = DateRangeFilter.all,
    this.customStart,
    this.customEnd,
    this.instrument,
    this.strategyId,
  });

  final DateRangeFilter dateRange;
  final DateTime? customStart;
  final DateTime? customEnd;
  final TradeInstrument? instrument;
  final String? strategyId;

  DashboardFilter copyWith({
    DateRangeFilter? dateRange,
    DateTime? customStart,
    DateTime? customEnd,
    TradeInstrument? instrument,
    String? strategyId,
    bool clearInstrument = false,
    bool clearStrategy = false,
  }) {
    return DashboardFilter(
      dateRange: dateRange ?? this.dateRange,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
      instrument: clearInstrument ? null : (instrument ?? this.instrument),
      strategyId: clearStrategy ? null : (strategyId ?? this.strategyId),
    );
  }

  @override
  List<Object?> get props => [dateRange, customStart, customEnd, instrument, strategyId];
}

class PerformanceMetrics extends Equatable {
  const PerformanceMetrics({
    required this.totalPnl,
    required this.winRate,
    required this.totalTrades,
    required this.avgRiskReward,
    required this.profitFactor,
  });

  final double totalPnl;
  final double winRate;
  final int totalTrades;
  final double avgRiskReward;
  final double profitFactor;

  @override
  List<Object?> get props => [totalPnl, winRate, totalTrades, avgRiskReward, profitFactor];
}

class EquityPoint extends Equatable {
  const EquityPoint({required this.date, required this.cumulativePnl});

  final DateTime date;
  final double cumulativePnl;

  @override
  List<Object?> get props => [date, cumulativePnl];
}

class ChartBreakdown extends Equatable {
  const ChartBreakdown({required this.label, required this.value, this.count = 0});

  final String label;
  final double value;
  final int count;

  @override
  List<Object?> get props => [label, value, count];
}

class TradeHighlight extends Equatable {
  const TradeHighlight({required this.trade, required this.pnl});

  final Trade trade;
  final double pnl;

  @override
  List<Object?> get props => [trade, pnl];
}

class StreakInfo extends Equatable {
  const StreakInfo({
    required this.currentStreak,
    required this.isWinStreak,
    required this.longestWinStreak,
    required this.longestLossStreak,
  });

  final int currentStreak;
  final bool isWinStreak;
  final int longestWinStreak;
  final int longestLossStreak;

  @override
  List<Object?> get props => [currentStreak, isWinStreak, longestWinStreak, longestLossStreak];
}

class DailyTradeSummary extends Equatable {
  const DailyTradeSummary({
    required this.date,
    required this.pnl,
    required this.tradeCount,
  });

  final DateTime date;
  final double pnl;
  final int tradeCount;

  @override
  List<Object?> get props => [date, pnl, tradeCount];
}

class RecapSummary extends Equatable {
  const RecapSummary({
    required this.periodLabel,
    required this.tradeCount,
    required this.winRate,
    required this.totalPnl,
    required this.bestInstrument,
  });

  final String periodLabel;
  final int tradeCount;
  final double winRate;
  final double totalPnl;
  final String bestInstrument;

  @override
  List<Object?> get props => [periodLabel, tradeCount, winRate, totalPnl, bestInstrument];
}
