import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../trade/domain/usecases/trade_usecases.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/utils/dashboard_analytics.dart';

class RecapPage extends StatefulWidget {
  const RecapPage({super.key});

  @override
  State<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  late final GetTrades _getTrades = sl<GetTrades>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recapTitle)),
      body: FutureBuilder(
        future: _getTrades(const NoParams()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          final trades = snapshot.data!;
          final weekly = DashboardAnalytics.weeklyRecap(trades);
          final monthly = DashboardAnalytics.monthlyRecap(trades);

          return ListView(
            padding: const EdgeInsets.all(AppDimens.spacingLg),
            children: [
              _RecapCard(summary: weekly),
              const SizedBox(height: AppDimens.spacingLg),
              _RecapCard(summary: monthly),
            ],
          );
        },
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.summary});

  final RecapSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.periodLabel, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppDimens.spacingMd),
            Text(
              '${summary.tradeCount} ${AppStrings.recapTrades} · ${CurrencyFormatter.formatPercent(summary.winRate)} ${AppStrings.winRate.toLowerCase()}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimens.spacingSm),
            Text(
              CurrencyFormatter.formatSigned(summary.totalPnl),
              style: AppTextStyles.metricValue.copyWith(
                color: summary.totalPnl >= 0 ? AppColors.profit : AppColors.loss,
              ),
            ),
            const SizedBox(height: AppDimens.spacingSm),
            Text(
              '${AppStrings.recapBestPair}: ${summary.bestInstrument}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
