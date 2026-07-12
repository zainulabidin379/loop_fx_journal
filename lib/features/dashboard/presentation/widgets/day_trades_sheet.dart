import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../trade/domain/entities/trade.dart';

class DayTradesSheet extends StatelessWidget {
  const DayTradesSheet({
    super.key,
    required this.date,
    required this.trades,
  });

  final DateTime date;
  final List<Trade> trades;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required List<Trade> trades,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (_) => DayTradesSheet(date: date, trades: trades),
    );
  }

  double get _totalPnl => trades.fold<double>(0, (sum, t) => sum + (t.pnl ?? 0));

  double get _winRate {
    if (trades.isEmpty) return 0;
    final wins = trades.where((t) => t.outcome == TradeOutcome.win).length;
    return (wins / trades.length) * 100;
  }

  Color _outcomeColor(Trade trade) {
    return switch (trade.outcome) {
      TradeOutcome.win => AppColors.profit,
      TradeOutcome.loss => AppColors.loss,
      TradeOutcome.breakeven => AppColors.breakeven,
      TradeOutcome.open => AppColors.open,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pnlColor = _totalPnl >= 0 ? AppColors.profit : AppColors.loss;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: trades.length <= 2 ? 0.45 : 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppDimens.spacingSm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormatter.formatDate(date), style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppDimens.spacingMd),
                  if (trades.isEmpty)
                    Text(AppStrings.calendarNoTrades, style: AppTextStyles.bodyMedium)
                  else ...[
                    Text(
                      CurrencyFormatter.format(_totalPnl),
                      style: AppTextStyles.metricValue.copyWith(color: pnlColor),
                    ),
                    const SizedBox(height: AppDimens.spacingXs),
                    Text(
                      '${trades.length} ${AppStrings.calendarTrades} · ${CurrencyFormatter.formatPercent(_winRate)} ${AppStrings.winRate.toLowerCase()}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trades.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.only(
                    left: AppDimens.spacingLg,
                    right: AppDimens.spacingLg,
                    bottom: AppDimens.spacingXxl,
                  ),
                  itemCount: trades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppDimens.spacingSm),
                  itemBuilder: (context, index) {
                    final trade = trades[index];
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/trades/${trade.id}');
                        },
                        title: Text(
                          '${trade.instrumentLabel} · ${trade.direction.label}',
                          style: AppTextStyles.titleMedium,
                        ),
                        subtitle: Text(
                          DateFormatter.formatDateTime(trade.exitDateTime ?? trade.entryDateTime),
                          style: AppTextStyles.bodySmall,
                        ),
                        trailing: Text(
                          trade.pnl != null ? CurrencyFormatter.format(trade.pnl!) : trade.outcome.label,
                          style: AppTextStyles.bodyMedium.copyWith(color: _outcomeColor(trade)),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
