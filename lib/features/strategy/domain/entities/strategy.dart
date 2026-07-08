import 'package:equatable/equatable.dart';

class Strategy extends Equatable {
  const Strategy({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final bool isActive;

  Strategy copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Strategy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, isActive];
}
