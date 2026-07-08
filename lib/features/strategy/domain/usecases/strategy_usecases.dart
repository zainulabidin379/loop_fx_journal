import '../../../../core/usecases/usecase.dart';
import '../entities/strategy.dart';
import '../repositories/strategy_repository.dart';

class GetStrategies implements UseCase<List<Strategy>, NoParams> {
  GetStrategies(this._repository);

  final StrategyRepository _repository;

  @override
  Future<List<Strategy>> call(NoParams params) => _repository.getStrategies();
}

class GetActiveStrategies implements UseCase<List<Strategy>, NoParams> {
  GetActiveStrategies(this._repository);

  final StrategyRepository _repository;

  @override
  Future<List<Strategy>> call(NoParams params) =>
      _repository.getActiveStrategies();
}

class GetStrategyById implements UseCase<Strategy?, String> {
  GetStrategyById(this._repository);

  final StrategyRepository _repository;

  @override
  Future<Strategy?> call(String params) => _repository.getStrategyById(params);
}

class AddStrategy implements UseCase<void, Strategy> {
  AddStrategy(this._repository);

  final StrategyRepository _repository;

  @override
  Future<void> call(Strategy params) => _repository.addStrategy(params);
}

class UpdateStrategy implements UseCase<void, Strategy> {
  UpdateStrategy(this._repository);

  final StrategyRepository _repository;

  @override
  Future<void> call(Strategy params) => _repository.updateStrategy(params);
}

class ArchiveStrategy implements UseCase<void, Strategy> {
  ArchiveStrategy(this._repository);

  final StrategyRepository _repository;

  @override
  Future<void> call(Strategy params) =>
      _repository.updateStrategy(params.copyWith(isActive: false));
}
