import 'package:hive_flutter/hive_flutter.dart';
import '../models/trade_model.dart';
import '../../domain/entities/trade.dart';

class HiveTradeDatasource {
  static const String boxName = 'trades';

  Box<TradeModel>? _box;

  Future<Box<TradeModel>> get box async {
    _box ??= await Hive.openBox<TradeModel>(boxName);
    return _box!;
  }

  Future<List<Trade>> getAll() async {
    final tradesBox = await box;
    return tradesBox.values.map((m) => m.toEntity()).toList()
      ..sort((a, b) => b.entryDateTime.compareTo(a.entryDateTime));
  }

  Future<Trade?> getById(String id) async {
    final tradesBox = await box;
    final model = tradesBox.get(id);
    return model?.toEntity();
  }

  Future<void> save(Trade trade) async {
    final tradesBox = await box;
    await tradesBox.put(trade.id, TradeModel.fromEntity(trade));
  }

  Future<void> delete(String id) async {
    final tradesBox = await box;
    await tradesBox.delete(id);
  }

  Future<void> clear() async {
    final tradesBox = await box;
    await tradesBox.clear();
  }

  Future<void> replaceAll(List<Trade> trades) async {
    final tradesBox = await box;
    await tradesBox.clear();
    for (final trade in trades) {
      await tradesBox.put(trade.id, TradeModel.fromEntity(trade));
    }
  }
}
