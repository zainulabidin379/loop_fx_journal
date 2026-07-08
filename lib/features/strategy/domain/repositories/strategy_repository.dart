import '../entities/strategy.dart';

abstract class StrategyRepository {
  Future<List<Strategy>> getStrategies();
  Future<Strategy?> getStrategyById(String id);
  Future<void> addStrategy(Strategy strategy);
  Future<void> updateStrategy(Strategy strategy);
  Future<void> deleteStrategy(String id);
  Future<List<Strategy>> getActiveStrategies();
  Future<void> clearAll();
  Future<void> replaceAll(List<Strategy> strategies);
}
