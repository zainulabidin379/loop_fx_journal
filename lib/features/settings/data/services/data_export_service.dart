import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../strategy/domain/entities/strategy.dart';
import '../../../strategy/domain/repositories/strategy_repository.dart';
import '../../../trade/domain/entities/trade.dart';
import '../../../trade/domain/repositories/trade_repository.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class DataExportService {
  DataExportService({required this._tradeRepository, required this._strategyRepository, required this._settingsRepository});

  final TradeRepository _tradeRepository;
  final StrategyRepository _strategyRepository;
  final SettingsRepository _settingsRepository;

  Future<void> exportJson() async {
    final data = await _buildExportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await _shareFile('loop_backup.json', jsonString);
  }

  Future<void> exportCsv() async {
    final trades = await _tradeRepository.getTrades();
    final buffer = StringBuffer()
      ..writeln('id,instrument,direction,entryPrice,exitPrice,stopLoss,takeProfit,lotSize,entryDate,exitDate,outcome,pnl,strategyId,notes');
    for (final trade in trades) {
      buffer.writeln(
        [
          trade.id,
          trade.instrumentLabel,
          trade.direction.name,
          trade.entryPrice,
          trade.exitPrice ?? '',
          trade.stopLoss,
          trade.takeProfit ?? '',
          trade.lotSize,
          trade.entryDateTime.toIso8601String(),
          trade.exitDateTime?.toIso8601String() ?? '',
          trade.outcome.name,
          trade.pnl ?? '',
          trade.strategyId ?? '',
          _escapeCsv(trade.notes ?? ''),
        ].join(','),
      );
    }
    await _shareFile('loop_trades.csv', buffer.toString());
  }

  Future<void> importJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final trades = (data['trades'] as List<dynamic>? ?? []).map((e) => _tradeFromJson(e as Map<String, dynamic>)).toList();
    final strategies = (data['strategies'] as List<dynamic>? ?? []).map((e) => _strategyFromJson(e as Map<String, dynamic>)).toList();
    final settingsJson = data['settings'] as Map<String, dynamic>?;
    await _tradeRepository.replaceAll(trades);
    await _strategyRepository.replaceAll(strategies);
    if (settingsJson != null) {
      await _settingsRepository.updateSettings(_settingsFromJson(settingsJson));
    }
  }

  Future<Map<String, dynamic>> _buildExportData() async {
    final trades = await _tradeRepository.getTrades();
    final strategies = await _strategyRepository.getStrategies();
    final settings = await _settingsRepository.getSettings();
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'trades': trades.map(_tradeToJson).toList(),
      'strategies': strategies.map(_strategyToJson).toList(),
      'settings': _settingsToJson(settings),
    };
  }

  Future<void> _shareFile(String fileName, String content) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'LOOP backup');
  }

  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  Map<String, dynamic> _tradeToJson(Trade trade) => {
    'id': trade.id,
    'instrument': trade.instrument.name,
    'customInstrument': trade.customInstrument,
    'direction': trade.direction.name,
    'entryPrice': trade.entryPrice,
    'exitPrice': trade.exitPrice,
    'stopLoss': trade.stopLoss,
    'takeProfit': trade.takeProfit,
    'lotSize': trade.lotSize,
    'entryDateTime': trade.entryDateTime.toIso8601String(),
    'exitDateTime': trade.exitDateTime?.toIso8601String(),
    'outcome': trade.outcome.name,
    'pnl': trade.pnl,
    'pnlPips': trade.pnlPips,
    'riskRewardPlanned': trade.riskRewardPlanned,
    'riskRewardActual': trade.riskRewardActual,
    'strategyId': trade.strategyId,
    'notes': trade.notes,
    'screenshotPaths': trade.screenshotPaths,
    'tags': trade.tags,
    'emotionBefore': trade.emotionBefore?.name,
    'emotionAfter': trade.emotionAfter?.name,
    'accountBalanceAtEntry': trade.accountBalanceAtEntry,
  };

  Trade _tradeFromJson(Map<String, dynamic> json) => Trade(
    id: json['id'] as String,
    instrument: TradeInstrument.values.byName(json['instrument'] as String),
    customInstrument: json['customInstrument'] as String?,
    direction: TradeDirection.values.byName(json['direction'] as String),
    entryPrice: (json['entryPrice'] as num).toDouble(),
    exitPrice: (json['exitPrice'] as num?)?.toDouble(),
    stopLoss: (json['stopLoss'] as num).toDouble(),
    takeProfit: (json['takeProfit'] as num?)?.toDouble(),
    lotSize: (json['lotSize'] as num).toDouble(),
    entryDateTime: DateTime.parse(json['entryDateTime'] as String),
    exitDateTime: json['exitDateTime'] != null ? DateTime.parse(json['exitDateTime'] as String) : null,
    outcome: TradeOutcome.values.byName(json['outcome'] as String),
    pnl: (json['pnl'] as num?)?.toDouble(),
    pnlPips: (json['pnlPips'] as num?)?.toDouble(),
    riskRewardPlanned: (json['riskRewardPlanned'] as num?)?.toDouble(),
    riskRewardActual: (json['riskRewardActual'] as num?)?.toDouble(),
    strategyId: json['strategyId'] as String?,
    notes: json['notes'] as String?,
    screenshotPaths: (json['screenshotPaths'] as List<dynamic>?)?.map((e) => e as String).toList(),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    emotionBefore: json['emotionBefore'] != null ? EmotionBefore.values.byName(json['emotionBefore'] as String) : null,
    emotionAfter: json['emotionAfter'] != null ? EmotionAfter.values.byName(json['emotionAfter'] as String) : null,
    accountBalanceAtEntry: (json['accountBalanceAtEntry'] as num?)?.toDouble(),
  );

  Map<String, dynamic> _strategyToJson(Strategy strategy) => {
    'id': strategy.id,
    'name': strategy.name,
    'description': strategy.description,
    'createdAt': strategy.createdAt.toIso8601String(),
    'isActive': strategy.isActive,
  };

  Strategy _strategyFromJson(Map<String, dynamic> json) => Strategy(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> _settingsToJson(AppSettings settings) => {
    'isBiometricEnabled': settings.isBiometricEnabled,
    'baseCurrency': settings.baseCurrency,
    'startingBalance': settings.startingBalance,
    'defaultRiskPercent': settings.defaultRiskPercent,
    'themeMode': settings.themeMode,
    'isReminderEnabled': settings.isReminderEnabled,
  };

  AppSettings _settingsFromJson(Map<String, dynamic> json) => AppSettings(
    isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
    baseCurrency: json['baseCurrency'] as String? ?? 'USD',
    startingBalance: (json['startingBalance'] as num?)?.toDouble(),
    defaultRiskPercent: (json['defaultRiskPercent'] as num?)?.toDouble(),
    themeMode: json['themeMode'] as String? ?? 'dark',
    isReminderEnabled: json['isReminderEnabled'] as bool? ?? false,
  );
}

class ClearAllData {
  ClearAllData({required this._tradeRepository, required this._strategyRepository, required this._settingsRepository});

  final TradeRepository _tradeRepository;
  final StrategyRepository _strategyRepository;
  final SettingsRepository _settingsRepository;

  Future<void> call() async {
    await _tradeRepository.clearAll();
    await _strategyRepository.clearAll();
    await _settingsRepository.clearSettings();
    await _settingsRepository.updateSettings(AppSettings.defaults);
  }
}
