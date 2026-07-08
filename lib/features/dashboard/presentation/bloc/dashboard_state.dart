part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.filter = const DashboardFilter(),
    this.allTrades = const [],
    this.filteredTrades = const [],
    this.openTrades = const [],
    this.strategyNames = const {},
    this.metrics = const PerformanceMetrics(
      totalPnl: 0,
      winRate: 0,
      totalTrades: 0,
      avgRiskReward: 0,
      profitFactor: 0,
    ),
    this.equityCurve = const [],
    this.winLoss = const [],
    this.byInstrument = const [],
    this.byStrategy = const [],
    this.byEmotion = const [],
    this.bestTrade,
    this.worstTrade,
    this.streak = const StreakInfo(
      currentStreak: 0,
      isWinStreak: false,
      longestWinStreak: 0,
      longestLossStreak: 0,
    ),
    this.weeklyRecap,
  });

  final DashboardStatus status;
  final DashboardFilter filter;
  final List<Trade> allTrades;
  final List<Trade> filteredTrades;
  final List<Trade> openTrades;
  final Map<String, String> strategyNames;
  final PerformanceMetrics metrics;
  final List<EquityPoint> equityCurve;
  final List<ChartBreakdown> winLoss;
  final List<ChartBreakdown> byInstrument;
  final List<ChartBreakdown> byStrategy;
  final List<ChartBreakdown> byEmotion;
  final TradeHighlight? bestTrade;
  final TradeHighlight? worstTrade;
  final StreakInfo streak;
  final RecapSummary? weeklyRecap;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardFilter? filter,
    List<Trade>? allTrades,
    List<Trade>? filteredTrades,
    List<Trade>? openTrades,
    Map<String, String>? strategyNames,
    PerformanceMetrics? metrics,
    List<EquityPoint>? equityCurve,
    List<ChartBreakdown>? winLoss,
    List<ChartBreakdown>? byInstrument,
    List<ChartBreakdown>? byStrategy,
    List<ChartBreakdown>? byEmotion,
    TradeHighlight? bestTrade,
    TradeHighlight? worstTrade,
    StreakInfo? streak,
    RecapSummary? weeklyRecap,
  }) {
    return DashboardState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      allTrades: allTrades ?? this.allTrades,
      filteredTrades: filteredTrades ?? this.filteredTrades,
      openTrades: openTrades ?? this.openTrades,
      strategyNames: strategyNames ?? this.strategyNames,
      metrics: metrics ?? this.metrics,
      equityCurve: equityCurve ?? this.equityCurve,
      winLoss: winLoss ?? this.winLoss,
      byInstrument: byInstrument ?? this.byInstrument,
      byStrategy: byStrategy ?? this.byStrategy,
      byEmotion: byEmotion ?? this.byEmotion,
      bestTrade: bestTrade ?? this.bestTrade,
      worstTrade: worstTrade ?? this.worstTrade,
      streak: streak ?? this.streak,
      weeklyRecap: weeklyRecap ?? this.weeklyRecap,
    );
  }

  @override
  List<Object?> get props => [
        status,
        filter,
        allTrades,
        filteredTrades,
        openTrades,
        strategyNames,
        metrics,
        equityCurve,
        winLoss,
        byInstrument,
        byStrategy,
        byEmotion,
        bestTrade,
        worstTrade,
        streak,
        weeklyRecap,
      ];
}
