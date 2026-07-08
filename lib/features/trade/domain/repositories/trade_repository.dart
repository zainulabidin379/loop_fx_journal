import '../entities/trade.dart';

abstract class TradeRepository {
  Future<List<Trade>> getTrades();
  Future<Trade?> getTradeById(String id);
  Future<void> addTrade(Trade trade);
  Future<void> updateTrade(Trade trade);
  Future<void> deleteTrade(String id);
  Future<List<Trade>> getOpenTrades();
  Future<void> clearAll();
  Future<void> replaceAll(List<Trade> trades);
}
