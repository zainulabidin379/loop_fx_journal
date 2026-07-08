import '../../../../core/usecases/usecase.dart';
import '../entities/trade.dart';
import '../repositories/trade_repository.dart';

class GetTrades implements UseCase<List<Trade>, NoParams> {
  GetTrades(this._repository);

  final TradeRepository _repository;

  @override
  Future<List<Trade>> call(NoParams params) => _repository.getTrades();
}

class GetTradeById implements UseCase<Trade?, String> {
  GetTradeById(this._repository);

  final TradeRepository _repository;

  @override
  Future<Trade?> call(String params) => _repository.getTradeById(params);
}

class AddTrade implements UseCase<void, Trade> {
  AddTrade(this._repository);

  final TradeRepository _repository;

  @override
  Future<void> call(Trade params) => _repository.addTrade(params);
}

class UpdateTrade implements UseCase<void, Trade> {
  UpdateTrade(this._repository);

  final TradeRepository _repository;

  @override
  Future<void> call(Trade params) => _repository.updateTrade(params);
}

class DeleteTrade implements UseCase<void, String> {
  DeleteTrade(this._repository);

  final TradeRepository _repository;

  @override
  Future<void> call(String params) => _repository.deleteTrade(params);
}

class GetOpenTrades implements UseCase<List<Trade>, NoParams> {
  GetOpenTrades(this._repository);

  final TradeRepository _repository;

  @override
  Future<List<Trade>> call(NoParams params) => _repository.getOpenTrades();
}
