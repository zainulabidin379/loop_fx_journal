part of 'trade_list_bloc.dart';

sealed class TradeListEvent extends Equatable {
  const TradeListEvent();

  @override
  List<Object?> get props => [];
}

class TradeListLoadRequested extends TradeListEvent {
  const TradeListLoadRequested();
}

class TradeDeleteRequested extends TradeListEvent {
  const TradeDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
