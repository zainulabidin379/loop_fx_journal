import '../../../trade/domain/entities/trade.dart';
import '../entities/dashboard_entities.dart';

abstract final class DashboardAnalytics {
  static List<Trade> filterTrades(List<Trade> trades, DashboardFilter filter) {
    return trades.where((trade) {
      if (trade.isOpen) return false;
      if (!_matchesDateRange(trade, filter)) return false;
      if (filter.instrument != null && trade.instrument != filter.instrument) {
        return false;
      }
      if (filter.strategyId != null && trade.strategyId != filter.strategyId) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.entryDateTime.compareTo(b.entryDateTime));
  }

  static bool _matchesDateRange(Trade trade, DashboardFilter filter) {
    final now = DateTime.now();
    final exitDate = trade.exitDateTime ?? trade.entryDateTime;
    switch (filter.dateRange) {
      case DateRangeFilter.d7:
        return exitDate.isAfter(now.subtract(const Duration(days: 7)));
      case DateRangeFilter.d30:
        return exitDate.isAfter(now.subtract(const Duration(days: 30)));
      case DateRangeFilter.d90:
        return exitDate.isAfter(now.subtract(const Duration(days: 90)));
      case DateRangeFilter.custom:
        if (filter.customStart == null || filter.customEnd == null) return true;
        return !exitDate.isBefore(filter.customStart!) &&
            !exitDate.isAfter(filter.customEnd!);
      case DateRangeFilter.all:
        return true;
    }
  }

  static PerformanceMetrics computeMetrics(List<Trade> trades) {
    if (trades.isEmpty) {
      return const PerformanceMetrics(
        totalPnl: 0,
        winRate: 0,
        totalTrades: 0,
        avgRiskReward: 0,
        profitFactor: 0,
      );
    }

    final closed = trades.where((t) => t.pnl != null).toList();
    final wins = closed.where((t) => t.outcome == TradeOutcome.win).toList();
    final losses = closed.where((t) => t.outcome == TradeOutcome.loss).toList();
    final totalPnl = closed.fold<double>(0, (sum, t) => sum + (t.pnl ?? 0));
    final winRate = closed.isEmpty ? 0.0 : (wins.length / closed.length) * 100;
    final rrValues = closed
        .where((t) => t.riskRewardActual != null)
        .map((t) => t.riskRewardActual!)
        .toList();
    final avgRR = rrValues.isEmpty
        ? 0.0
        : rrValues.reduce((a, b) => a + b) / rrValues.length;
    final grossProfit = wins.fold<double>(0, (sum, t) => sum + (t.pnl ?? 0));
    final grossLoss = losses.fold<double>(0, (sum, t) => sum + (t.pnl ?? 0).abs());
    final profitFactor = grossLoss == 0 ? grossProfit : grossProfit / grossLoss;

    return PerformanceMetrics(
      totalPnl: totalPnl,
      winRate: winRate,
      totalTrades: closed.length,
      avgRiskReward: avgRR,
      profitFactor: profitFactor,
    );
  }

  static List<EquityPoint> computeEquityCurve(List<Trade> trades) {
    double cumulative = 0;
    return trades.map((trade) {
      cumulative += trade.pnl ?? 0;
      return EquityPoint(
        date: trade.exitDateTime ?? trade.entryDateTime,
        cumulativePnl: cumulative,
      );
    }).toList();
  }

  static List<ChartBreakdown> winLossBreakdown(List<Trade> trades) {
    final wins = trades.where((t) => t.outcome == TradeOutcome.win).length;
    final losses = trades.where((t) => t.outcome == TradeOutcome.loss).length;
    final breakeven = trades.where((t) => t.outcome == TradeOutcome.breakeven).length;
    return [
      ChartBreakdown(label: 'Wins', value: wins.toDouble(), count: wins),
      ChartBreakdown(label: 'Losses', value: losses.toDouble(), count: losses),
      ChartBreakdown(label: 'Breakeven', value: breakeven.toDouble(), count: breakeven),
    ];
  }

  static List<ChartBreakdown> byInstrument(List<Trade> trades) {
    final map = <String, double>{};
    for (final trade in trades) {
      final key = trade.instrumentLabel;
      map[key] = (map[key] ?? 0) + (trade.pnl ?? 0);
    }
    return map.entries
        .map((e) => ChartBreakdown(label: e.key, value: e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<ChartBreakdown> byStrategy(List<Trade> trades, Map<String, String> strategyNames) {
    final map = <String, double>{};
    for (final trade in trades) {
      final key = strategyNames[trade.strategyId] ?? 'None';
      map[key] = (map[key] ?? 0) + (trade.pnl ?? 0);
    }
    return map.entries
        .map((e) => ChartBreakdown(label: e.key, value: e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static List<ChartBreakdown> byEmotion(List<Trade> trades) {
    final map = <String, double>{};
    for (final trade in trades) {
      final key = trade.emotionBefore?.label ?? 'Unknown';
      map[key] = (map[key] ?? 0) + (trade.pnl ?? 0);
    }
    return map.entries
        .map((e) => ChartBreakdown(label: e.key, value: e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  static TradeHighlight? bestTrade(List<Trade> trades) {
    final closed = trades.where((t) => t.pnl != null).toList();
    if (closed.isEmpty) return null;
    closed.sort((a, b) => (b.pnl ?? 0).compareTo(a.pnl ?? 0));
    return TradeHighlight(trade: closed.first, pnl: closed.first.pnl!);
  }

  static TradeHighlight? worstTrade(List<Trade> trades) {
    final closed = trades.where((t) => t.pnl != null).toList();
    if (closed.isEmpty) return null;
    closed.sort((a, b) => (a.pnl ?? 0).compareTo(b.pnl ?? 0));
    return TradeHighlight(trade: closed.first, pnl: closed.first.pnl!);
  }

  static StreakInfo computeStreak(List<Trade> trades) {
    final closed = trades
        .where((t) => t.outcome != TradeOutcome.open && t.outcome != TradeOutcome.breakeven)
        .toList()
      ..sort((a, b) => (b.exitDateTime ?? b.entryDateTime)
          .compareTo(a.exitDateTime ?? a.entryDateTime));

    if (closed.isEmpty) {
      return const StreakInfo(
        currentStreak: 0,
        isWinStreak: false,
        longestWinStreak: 0,
        longestLossStreak: 0,
      );
    }

    int current = 1;
    final isWin = closed.first.outcome == TradeOutcome.win;
    for (var i = 1; i < closed.length; i++) {
      final same = (closed[i].outcome == TradeOutcome.win) == isWin;
      if (same) {
        current++;
      } else {
        break;
      }
    }

    int longestWin = 0;
    int longestLoss = 0;
    int streak = 1;
    for (var i = 1; i < closed.length; i++) {
      final prevWin = closed[i - 1].outcome == TradeOutcome.win;
      final currWin = closed[i].outcome == TradeOutcome.win;
      if (prevWin == currWin) {
        streak++;
      } else {
        if (prevWin) {
          longestWin = streak > longestWin ? streak : longestWin;
        } else {
          longestLoss = streak > longestLoss ? streak : longestLoss;
        }
        streak = 1;
      }
    }
    if (closed.last.outcome == TradeOutcome.win) {
      longestWin = streak > longestWin ? streak : longestWin;
    } else {
      longestLoss = streak > longestLoss ? streak : longestLoss;
    }

    return StreakInfo(
      currentStreak: current,
      isWinStreak: isWin,
      longestWinStreak: longestWin,
      longestLossStreak: longestLoss,
    );
  }

  static RecapSummary weeklyRecap(List<Trade> allTrades) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final filter = DashboardFilter(
      dateRange: DateRangeFilter.custom,
      customStart: DateTime(start.year, start.month, start.day),
      customEnd: now,
    );
    return _recap(allTrades, filter, 'This Week');
  }

  static RecapSummary monthlyRecap(List<Trade> allTrades) {
    final now = DateTime.now();
    final filter = DashboardFilter(
      dateRange: DateRangeFilter.custom,
      customStart: DateTime(now.year, now.month, 1),
      customEnd: now,
    );
    return _recap(allTrades, filter, 'This Month');
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime? _tradeDate(Trade trade) {
    if (trade.isOpen) return null;
    final d = trade.exitDateTime ?? trade.entryDateTime;
    return _dateOnly(d);
  }

  static Map<DateTime, DailyTradeSummary> dailySummariesForMonth(
    List<Trade> allTrades,
    int year,
    int month,
  ) {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
    final trades = filterTrades(
      allTrades,
      DashboardFilter(
        dateRange: DateRangeFilter.custom,
        customStart: monthStart,
        customEnd: monthEnd,
      ),
    );

    final map = <DateTime, DailyTradeSummary>{};
    for (final trade in trades) {
      final key = _dateOnly(trade.exitDateTime ?? trade.entryDateTime);
      final existing = map[key];
      map[key] = DailyTradeSummary(
        date: key,
        pnl: (existing?.pnl ?? 0) + (trade.pnl ?? 0),
        tradeCount: (existing?.tradeCount ?? 0) + 1,
      );
    }
    return map;
  }

  static List<Trade> tradesForDay(List<Trade> allTrades, DateTime date) {
    final day = _dateOnly(date);
    return allTrades.where((trade) {
      if (trade.isOpen) return false;
      return _tradeDate(trade) == day;
    }).toList()
      ..sort((a, b) {
        final aDate = a.exitDateTime ?? a.entryDateTime;
        final bDate = b.exitDateTime ?? b.entryDateTime;
        return aDate.compareTo(bDate);
      });
  }

  static DateTime? earliestTradeMonth(List<Trade> allTrades) {
    final closed = allTrades.where((t) => !t.isOpen).toList();
    if (closed.isEmpty) return null;
    closed.sort((a, b) {
      final aDate = a.exitDateTime ?? a.entryDateTime;
      final bDate = b.exitDateTime ?? b.entryDateTime;
      return aDate.compareTo(bDate);
    });
    final earliest = closed.first.exitDateTime ?? closed.first.entryDateTime;
    return DateTime(earliest.year, earliest.month);
  }

  static RecapSummary _recap(List<Trade> allTrades, DashboardFilter filter, String label) {
    final trades = filterTrades(allTrades, filter);
    final metrics = computeMetrics(trades);
    final byInst = byInstrument(trades);
    final best = byInst.isEmpty ? '—' : byInst.first.label;
    return RecapSummary(
      periodLabel: label,
      tradeCount: metrics.totalTrades,
      winRate: metrics.winRate,
      totalPnl: metrics.totalPnl,
      bestInstrument: best,
    );
  }
}
