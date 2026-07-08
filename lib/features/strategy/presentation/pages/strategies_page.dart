import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../dashboard/domain/utils/dashboard_analytics.dart';
import '../../../trade/domain/usecases/trade_usecases.dart';
import '../../domain/entities/strategy.dart';
import '../../domain/usecases/strategy_usecases.dart';

class StrategiesPage extends StatefulWidget {
  const StrategiesPage({super.key});

  @override
  State<StrategiesPage> createState() => _StrategiesPageState();
}

class _StrategiesPageState extends State<StrategiesPage> {
  List<Strategy> _strategies = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final strategies = await sl<GetStrategies>()(const NoParams());
    if (mounted) setState(() => _strategies = strategies);
  }

  Future<void> _showAddDialog({Strategy? existing}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? AppStrings.addStrategy : AppStrings.editStrategy),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: AppStrings.strategyName),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: AppStrings.strategyDescription),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(AppStrings.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(AppStrings.save)),
        ],
      ),
    );

    if (saved == true && nameController.text.isNotEmpty) {
      final strategy = Strategy(
        id: existing?.id ?? const Uuid().v4(),
        name: nameController.text,
        description: descController.text,
        createdAt: existing?.createdAt ?? DateTime.now(),
        isActive: existing?.isActive ?? true,
      );
      if (existing == null) {
        await sl<AddStrategy>()(strategy);
      } else {
        await sl<UpdateStrategy>()(strategy);
      }
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.strategiesTitle)),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(), child: const Icon(Icons.add)),
      body: _strategies.isEmpty
          ? const EmptyState(title: AppStrings.noStrategies)
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimens.spacingLg),
              itemCount: _strategies.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimens.spacingSm),
              itemBuilder: (context, index) {
                final strategy = _strategies[index];
                return Card(
                  child: ListTile(
                    title: Text(strategy.name, style: AppTextStyles.titleMedium),
                    subtitle: Text(
                      strategy.isActive ? strategy.description : AppStrings.archived,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => context.push('/settings/strategies/${strategy.id}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _showAddDialog(existing: strategy);
                        } else if (value == 'archive') {
                          await sl<ArchiveStrategy>()(strategy);
                          await _load();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text(AppStrings.editStrategy)),
                        const PopupMenuItem(value: 'archive', child: Text(AppStrings.archiveStrategy)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class StrategyDetailPage extends StatefulWidget {
  const StrategyDetailPage({super.key, required this.strategyId});

  final String strategyId;

  @override
  State<StrategyDetailPage> createState() => _StrategyDetailPageState();
}

class _StrategyDetailPageState extends State<StrategyDetailPage> {
  Strategy? _strategy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final strategy = await sl<GetStrategyById>()(widget.strategyId);
    if (mounted) setState(() => _strategy = strategy);
  }

  @override
  Widget build(BuildContext context) {
    if (_strategy == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: sl<GetTrades>()(const NoParams()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final trades = snapshot.data!.where((t) => t.strategyId == widget.strategyId && !t.isOpen).toList();
        final metrics = DashboardAnalytics.computeMetrics(trades);

        return Scaffold(
          appBar: AppBar(title: Text(_strategy!.name)),
          body: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_strategy!.description, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppDimens.spacingXl),
                Text(AppStrings.strategyPerformance, style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppDimens.spacingLg),
                Text('${AppStrings.winRate}: ${CurrencyFormatter.formatPercent(metrics.winRate)}',
                    style: AppTextStyles.bodyLarge),
                Text('${AppStrings.avgRiskReward}: ${CurrencyFormatter.formatRatio(metrics.avgRiskReward)}',
                    style: AppTextStyles.bodyLarge),
                Text('${AppStrings.totalTrades}: ${metrics.totalTrades}', style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
        );
      },
    );
  }
}
