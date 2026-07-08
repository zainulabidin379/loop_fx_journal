import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/trade.dart';
import '../../domain/usecases/trade_usecases.dart';
import '../bloc/trade_list_bloc.dart';

class TradeDetailPage extends StatefulWidget {
  const TradeDetailPage({super.key, required this.tradeId});

  final String tradeId;

  @override
  State<TradeDetailPage> createState() => _TradeDetailPageState();
}

class _TradeDetailPageState extends State<TradeDetailPage> {
  Trade? _trade;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trade = await sl<GetTradeById>()(widget.tradeId);
    if (mounted) setState(() => _trade = trade);
  }

  @override
  Widget build(BuildContext context) {
    if (_trade == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    final trade = _trade!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tradeDetail),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => context.push('/trades/${trade.id}/edit')),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(AppStrings.deleteTrade),
                  content: const Text(AppStrings.deleteTradeConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.delete)),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                context.read<TradeListBloc>().add(TradeDeleteRequested(trade.id));
                context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        children: [
          Text('${trade.instrumentLabel} · ${trade.direction.label}', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppDimens.spacingSm),
          Text(
            trade.outcome.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: trade.outcome == TradeOutcome.loss
                  ? AppColors.loss
                  : trade.outcome == TradeOutcome.win
                  ? AppColors.profit
                  : trade.outcome == TradeOutcome.breakeven
                  ? AppColors.breakeven
                  : AppColors.open,
            ),
          ),
          const SizedBox(height: AppDimens.spacingXl),
          _DetailRow(label: AppStrings.entryPrice, value: NumberFormatter.format(trade.entryPrice)),
          if (trade.exitPrice != null) _DetailRow(label: AppStrings.exitPrice, value: NumberFormatter.format(trade.exitPrice)),
          _DetailRow(label: AppStrings.stopLoss, value: NumberFormatter.format(trade.stopLoss)),
          if (trade.takeProfit != null) _DetailRow(label: AppStrings.takeProfit, value: NumberFormatter.format(trade.takeProfit)),
          _DetailRow(label: AppStrings.lotSize, value: NumberFormatter.format(trade.lotSize)),
          _DetailRow(label: AppStrings.entryDate, value: DateFormatter.formatDateTime(trade.entryDateTime)),
          if (trade.exitDateTime != null) _DetailRow(label: AppStrings.exitDate, value: DateFormatter.formatDateTime(trade.exitDateTime!)),
          if (trade.pnl != null) _DetailRow(label: AppStrings.pnl, value: CurrencyFormatter.format(trade.pnl!)),
          if (trade.pnlPips != null) _DetailRow(label: AppStrings.pnlPips, value: NumberFormatter.format(trade.pnlPips)),
          if (trade.riskRewardPlanned != null)
            _DetailRow(label: AppStrings.plannedRR, value: CurrencyFormatter.formatRatio(trade.riskRewardPlanned)),
          if (trade.riskRewardActual != null)
            _DetailRow(label: AppStrings.actualRR, value: CurrencyFormatter.formatRatio(trade.riskRewardActual)),
          if (trade.notes != null && trade.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingLg),
            Text(AppStrings.notes, style: AppTextStyles.titleMedium),
            Text(trade.notes!, style: AppTextStyles.bodyMedium),
          ],
          if (trade.tags != null && trade.tags!.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingLg),
            Text(AppStrings.tags, style: AppTextStyles.titleMedium),
            Wrap(
              spacing: AppDimens.spacingSm,
              children: trade.tags!.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],
          const SizedBox(height: AppDimens.spacingXl),
          if (trade.isOpen) AppButton(label: AppStrings.closeTrade, onPressed: () => context.push('/trades/${trade.id}/edit')),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
