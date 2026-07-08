import '../datasources/hive_trade_datasource.dart';
import '../../domain/entities/trade.dart';
import '../../domain/repositories/trade_repository.dart';

class TradeRepositoryImpl implements TradeRepository {
  TradeRepositoryImpl(this._datasource);

  final HiveTradeDatasource _datasource;

  @override
  Future<void> addTrade(Trade trade) => _datasource.save(trade);

  @override
  Future<void> clearAll() => _datasource.clear();

  @override
  Future<void> deleteTrade(String id) => _datasource.delete(id);

  @override
  Future<List<Trade>> getOpenTrades() async {
    final trades = await _datasource.getAll();
    return trades.where((t) => t.isOpen).toList();
  }

  @override
  Future<Trade?> getTradeById(String id) => _datasource.getById(id);

  @override
  Future<List<Trade>> getTrades() => _datasource.getAll();

  @override
  Future<void> replaceAll(List<Trade> trades) => _datasource.replaceAll(trades);

  @override
  Future<void> updateTrade(Trade trade) => _datasource.save(trade);
}
