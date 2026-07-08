import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/trade.dart';
import '../bloc/trade_list_bloc.dart';

class TradeListPage extends StatefulWidget {
  const TradeListPage({super.key});

  @override
  State<TradeListPage> createState() => _TradeListPageState();
}

class _TradeListPageState extends State<TradeListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TradeListBloc>().add(const TradeListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tradesTitle)),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/trades/add'), child: const Icon(Icons.add)),
      body: BlocBuilder<TradeListBloc, TradeListState>(
        builder: (context, state) {
          if (state.status == TradeListStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (state.trades.isEmpty) {
            return EmptyState(
              title: AppStrings.noTradesYet,
              subtitle: AppStrings.noTradesSubtitle,
              actionLabel: AppStrings.addTrade,
              onAction: () => context.push('/trades/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimens.spacingLg),
            itemCount: state.trades.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.spacingSm),
            itemBuilder: (context, index) {
              final trade = state.trades[index];
              return _TradeTile(trade: trade);
            },
          );
        },
      ),
    );
  }
}

class _TradeTile extends StatelessWidget {
  const _TradeTile({required this.trade});

  final Trade trade;

  Color _outcomeColor() {
    return switch (trade.outcome) {
      TradeOutcome.win => AppColors.profit,
      TradeOutcome.loss => AppColors.loss,
      TradeOutcome.breakeven => AppColors.breakeven,
      TradeOutcome.open => AppColors.open,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('/trades/${trade.id}'),
        title: Text('${trade.instrumentLabel} · ${trade.direction.label}', style: AppTextStyles.titleMedium),
        subtitle: Text(DateFormatter.formatDateTime(trade.entryDateTime), style: AppTextStyles.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              trade.pnl != null ? CurrencyFormatter.format(trade.pnl!) : trade.outcome.label,
              style: AppTextStyles.bodyMedium.copyWith(color: _outcomeColor()),
            ),
          ],
        ),
      ),
    );
  }
}
