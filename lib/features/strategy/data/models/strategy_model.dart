import 'package:hive/hive.dart';
import '../../domain/entities/strategy.dart';

part 'strategy_model.g.dart';

@HiveType(typeId: 1)
class StrategyModel extends HiveObject {
  StrategyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.isActive,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool isActive;

  Strategy toEntity() {
    return Strategy(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  factory StrategyModel.fromEntity(Strategy strategy) {
    return StrategyModel(
      id: strategy.id,
      name: strategy.name,
      description: strategy.description,
      createdAt: strategy.createdAt,
      isActive: strategy.isActive,
    );
  }
}
