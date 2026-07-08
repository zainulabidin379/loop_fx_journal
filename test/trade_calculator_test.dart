import 'package:flutter_test/flutter_test.dart';
import 'package:loop_fx_journal/core/utils/currency_formatter.dart';
import 'package:loop_fx_journal/core/utils/number_formatter.dart';
import 'package:loop_fx_journal/features/trade/domain/entities/trade.dart';
import 'package:loop_fx_journal/features/trade/domain/utils/trade_calculator.dart';
import 'package:loop_fx_journal/features/dashboard/domain/utils/dashboard_analytics.dart';

void main() {
  group('NumberFormatter', () {
    test('formats values to two decimals', () {
      expect(NumberFormatter.format(1.234), '1.23');
      expect(NumberFormatter.format(10), '10.00');
    });

    test('rounds values to two decimals', () {
      expect(NumberFormatter.round(1.236), 1.24);
    });
  });

  group('CurrencyFormatter', () {
    test('formats percent to two decimals', () {
      expect(CurrencyFormatter.formatPercent(58.456), '58.46%');
    });
  });

  group('TradeCalculator', () {
    test('calculates planned risk reward', () {
      final rr = TradeCalculator.plannedRiskReward(
        direction: TradeDirection.long,
        entryPrice: 100,
        stopLoss: 95,
        takeProfit: 110,
      );
      expect(rr, closeTo(2.0, 0.01));
    });

    test('determines outcome from pnl', () {
      expect(TradeCalculator.outcomeFromPnl(10), TradeOutcome.win);
      expect(TradeCalculator.outcomeFromPnl(-5), TradeOutcome.loss);
      expect(TradeCalculator.outcomeFromPnl(0), TradeOutcome.breakeven);
    });
  });

  group('DashboardAnalytics', () {
    final trades = [
      Trade(
        id: '1',
        instrument: TradeInstrument.xauusd,
        direction: TradeDirection.long,
        entryPrice: 2000,
        exitPrice: 2010,
        stopLoss: 1990,
        lotSize: 0.1,
        entryDateTime: DateTime.now().subtract(const Duration(days: 2)),
        exitDateTime: DateTime.now().subtract(const Duration(days: 1)),
        outcome: TradeOutcome.win,
        pnl: 100,
        riskRewardActual: 1.0,
      ),
      Trade(
        id: '2',
        instrument: TradeInstrument.eurusd,
        direction: TradeDirection.short,
        entryPrice: 1.1,
        exitPrice: 1.105,
        stopLoss: 1.11,
        lotSize: 0.1,
        entryDateTime: DateTime.now().subtract(const Duration(days: 1)),
        exitDateTime: DateTime.now(),
        outcome: TradeOutcome.loss,
        pnl: -50,
        riskRewardActual: -0.5,
      ),
    ];

    test('computes performance metrics', () {
      final metrics = DashboardAnalytics.computeMetrics(trades);
      expect(metrics.totalTrades, 2);
      expect(metrics.totalPnl, 50);
      expect(metrics.winRate, 50);
    });

    test('computes streak info', () {
      final streak = DashboardAnalytics.computeStreak(trades);
      expect(streak.currentStreak, greaterThanOrEqualTo(1));
    });
  });
}
