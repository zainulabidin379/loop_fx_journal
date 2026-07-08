import '../entities/trade.dart';

abstract final class TradeCalculator {
  static double? plannedRiskReward({
    required TradeDirection direction,
    required double entryPrice,
    required double stopLoss,
    double? takeProfit,
  }) {
    if (takeProfit == null) return null;
    final risk = (entryPrice - stopLoss).abs();
    if (risk == 0) return null;
    final reward = (takeProfit - entryPrice).abs();
    return reward / risk;
  }

  static double? actualRiskReward({
    required TradeDirection direction,
    required double entryPrice,
    required double stopLoss,
    required double exitPrice,
  }) {
    final risk = (entryPrice - stopLoss).abs();
    if (risk == 0) return null;
    final reward = direction == TradeDirection.long
        ? exitPrice - entryPrice
        : entryPrice - exitPrice;
    return reward / risk;
  }

  static double? calculatePnlPips({
    required TradeInstrument instrument,
    required TradeDirection direction,
    required double entryPrice,
    required double exitPrice,
  }) {
    final pipSize = instrument.pipSize;
    final diff = direction == TradeDirection.long
        ? exitPrice - entryPrice
        : entryPrice - exitPrice;
    return diff / pipSize;
  }

  static TradeOutcome outcomeFromPnl(double? pnl) {
    if (pnl == null) return TradeOutcome.open;
    if (pnl > 0) return TradeOutcome.win;
    if (pnl < 0) return TradeOutcome.loss;
    return TradeOutcome.breakeven;
  }

  static double? suggestedLotSize({
    required double accountBalance,
    required double riskPercent,
    required double entryPrice,
    required double stopLoss,
    required TradeInstrument instrument,
  }) {
    final riskAmount = accountBalance * (riskPercent / 100);
    final stopDistance = (entryPrice - stopLoss).abs();
    if (stopDistance == 0) return null;

    // Simplified lot sizing for journal purposes
    final pipValue = instrument == TradeInstrument.xauusd ? 10.0 : 10.0;
    final pips = stopDistance / instrument.pipSize;
    if (pips == 0) return null;
    return riskAmount / (pips * pipValue);
  }
}
