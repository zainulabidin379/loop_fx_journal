import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../trade/domain/entities/trade.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_charts.dart';
import '../widgets/performance_calendar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  String _dateFilterLabel(DateRangeFilter filter) {
    return switch (filter) {
      DateRangeFilter.d7 => AppStrings.filter7d,
      DateRangeFilter.d30 => AppStrings.filter30d,
      DateRangeFilter.d90 => AppStrings.filter90d,
      DateRangeFilter.all => AppStrings.filterAll,
      DateRangeFilter.custom => AppStrings.filterCustom,
    };
  }

  DateRangeFilter _filterFromLabel(String label) {
    return switch (label) {
      AppStrings.filter7d => DateRangeFilter.d7,
      AppStrings.filter30d => DateRangeFilter.d30,
      AppStrings.filter90d => DateRangeFilter.d90,
      AppStrings.filterCustom => DateRangeFilter.custom,
      _ => DateRangeFilter.all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.logo, width: AppDimens.iconLg, height: AppDimens.iconLg),
            const SizedBox(width: AppDimens.spacingMd),
            Text(AppStrings.appName, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.accent)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/trades/add'),
        child: HugeIcon(icon: HugeIcons.strokeRoundedAdd01),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }

          if (state.filteredTrades.isEmpty && state.openTrades.isEmpty) {
            return EmptyState(
              title: AppStrings.noTradesYet,
              subtitle: AppStrings.noTradesSubtitle,
              actionLabel: AppStrings.addTrade,
              onAction: () => context.push('/trades/add'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.spacingLg),
              children: [
                FilterChipBar(
                  options: const [AppStrings.filter7d, AppStrings.filter30d, AppStrings.filter90d, AppStrings.filterAll],
                  selected: _dateFilterLabel(state.filter.dateRange),
                  onSelected: (label) => context.read<DashboardBloc>().add(DashboardFilterChanged(dateRange: _filterFromLabel(label))),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppDimens.spacingMd,
                  crossAxisSpacing: AppDimens.spacingMd,
                  childAspectRatio: 1.6,
                  children: [
                    MetricCard(
                      label: AppStrings.totalPnl,
                      value: CurrencyFormatter.format(state.metrics.totalPnl),
                      valueColor: state.metrics.totalPnl >= 0 ? AppColors.profit : AppColors.loss,
                    ),
                    MetricCard(label: AppStrings.winRate, value: CurrencyFormatter.formatPercent(state.metrics.winRate)),
                    MetricCard(label: AppStrings.totalTrades, value: '${state.metrics.totalTrades}'),
                    MetricCard(label: AppStrings.avgRiskReward, value: CurrencyFormatter.formatRatio(state.metrics.avgRiskReward)),
                  ],
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.equityCurve, style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppDimens.spacingMd),
                      EquityChart(points: state.equityCurve),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.winLossBreakdown, style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppDimens.spacingMd),
                      WinLossDonutChart(data: state.winLoss),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppCard(
                  child: BreakdownBarChart(data: state.byInstrument, title: AppStrings.performanceByInstrument),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppCard(
                  child: BreakdownBarChart(data: state.byStrategy, title: AppStrings.performanceByStrategy),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                AppCard(
                  child: BreakdownBarChart(data: state.byEmotion, title: AppStrings.performanceByEmotion),
                ),
                const SizedBox(height: AppDimens.spacingLg),
                _StreakCard(streak: state.streak),
                if (state.openTrades.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.spacingLg),
                  _OpenTradesSection(trades: state.openTrades),
                ],
                if (state.bestTrade != null || state.worstTrade != null) ...[
                  const SizedBox(height: AppDimens.spacingLg),
                  Row(
                    children: [
                      if (state.bestTrade != null)
                        Expanded(
                          child: _HighlightCard(title: AppStrings.bestTrade, highlight: state.bestTrade!),
                        ),
                      if (state.bestTrade != null && state.worstTrade != null) const SizedBox(width: AppDimens.spacingMd),
                      if (state.worstTrade != null)
                        Expanded(
                          child: _HighlightCard(title: AppStrings.worstTrade, highlight: state.worstTrade!),
                        ),
                    ],
                  ),
                ],
                if (state.weeklyRecap != null || state.monthlyRecap != null) ...[
                  const SizedBox(height: AppDimens.spacingLg),
                  if (state.weeklyRecap != null) _RecapCard(summary: state.weeklyRecap!),
                  if (state.weeklyRecap != null && state.monthlyRecap != null) const SizedBox(height: AppDimens.spacingMd),
                  if (state.monthlyRecap != null) _RecapCard(summary: state.monthlyRecap!),
                ],
                const SizedBox(height: AppDimens.spacingLg),
                PerformanceCalendar(trades: state.allTrades),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.streakTracker, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimens.spacingMd),
          Text(
            '${streak.currentStreak} ${streak.isWinStreak ? AppStrings.wins : AppStrings.losses}',
            style: AppTextStyles.metricValue.copyWith(color: streak.isWinStreak ? AppColors.profit : AppColors.loss),
          ),
          const SizedBox(height: AppDimens.spacingSm),
          Text('Best: ${streak.longestWinStreak}W / ${streak.longestLossStreak}L', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _OpenTradesSection extends StatelessWidget {
  const _OpenTradesSection({required this.trades});

  final List<Trade> trades;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.openTrades, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimens.spacingMd),
          ...trades.map(
            (trade) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(trade.instrumentLabel, style: AppTextStyles.bodyMedium),
              subtitle: Text('${trade.direction.label} · ${NumberFormatter.format(trade.entryPrice)}', style: AppTextStyles.bodySmall),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () => context.push('/trades/${trade.id}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.summary});

  final RecapSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
            CurrencyFormatter.format(summary.totalPnl),
            style: AppTextStyles.metricValue.copyWith(color: summary.totalPnl >= 0 ? AppColors.profit : AppColors.loss),
          ),
          const SizedBox(height: AppDimens.spacingSm),
          Text('${AppStrings.recapBestPair}: ${summary.bestInstrument}', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.title, required this.highlight});

  final String title;
  final TradeHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/trades/${highlight.trade.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium),
          const SizedBox(height: AppDimens.spacingSm),
          Text(highlight.trade.instrumentLabel, style: AppTextStyles.titleMedium),
          Text(
            CurrencyFormatter.format(highlight.pnl),
            style: AppTextStyles.metricValue.copyWith(fontSize: 20, color: highlight.pnl >= 0 ? AppColors.profit : AppColors.loss),
          ),
        ],
      ),
    );
  }
}
