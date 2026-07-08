import '../datasources/hive_strategy_datasource.dart';
import '../../domain/entities/strategy.dart';
import '../../domain/repositories/strategy_repository.dart';

class StrategyRepositoryImpl implements StrategyRepository {
  StrategyRepositoryImpl(this._datasource);

  final HiveStrategyDatasource _datasource;

  @override
  Future<void> addStrategy(Strategy strategy) => _datasource.save(strategy);

  @override
  Future<void> clearAll() => _datasource.clear();

  @override
  Future<void> deleteStrategy(String id) => _datasource.delete(id);

  @override
  Future<List<Strategy>> getActiveStrategies() async {
    final strategies = await _datasource.getAll();
    return strategies.where((s) => s.isActive).toList();
  }

  @override
  Future<Strategy?> getStrategyById(String id) => _datasource.getById(id);

  @override
  Future<List<Strategy>> getStrategies() => _datasource.getAll();

  @override
  Future<void> replaceAll(List<Strategy> strategies) =>
      _datasource.replaceAll(strategies);

  @override
  Future<void> updateStrategy(Strategy strategy) => _datasource.save(strategy);
}
