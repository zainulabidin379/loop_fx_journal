import 'package:hive_flutter/hive_flutter.dart';
import '../models/strategy_model.dart';
import '../../domain/entities/strategy.dart';

class HiveStrategyDatasource {
  static const String boxName = 'strategies';

  Box<StrategyModel>? _box;

  Future<Box<StrategyModel>> get box async {
    _box ??= await Hive.openBox<StrategyModel>(boxName);
    return _box!;
  }

  Future<List<Strategy>> getAll() async {
    final strategiesBox = await box;
    return strategiesBox.values.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<Strategy?> getById(String id) async {
    final strategiesBox = await box;
    return strategiesBox.get(id)?.toEntity();
  }

  Future<void> save(Strategy strategy) async {
    final strategiesBox = await box;
    await strategiesBox.put(strategy.id, StrategyModel.fromEntity(strategy));
  }

  Future<void> delete(String id) async {
    final strategiesBox = await box;
    await strategiesBox.delete(id);
  }

  Future<void> clear() async {
    final strategiesBox = await box;
    await strategiesBox.clear();
  }

  Future<void> replaceAll(List<Strategy> strategies) async {
    final strategiesBox = await box;
    await strategiesBox.clear();
    for (final strategy in strategies) {
      await strategiesBox.put(strategy.id, StrategyModel.fromEntity(strategy));
    }
  }
}
