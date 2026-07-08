part of 'trade_list_bloc.dart';

enum TradeListStatus { initial, loading, loaded, error }

class TradeListState extends Equatable {
  const TradeListState({
    this.status = TradeListStatus.initial,
    this.trades = const [],
  });

  final TradeListStatus status;
  final List<Trade> trades;

  TradeListState copyWith({
    TradeListStatus? status,
    List<Trade>? trades,
  }) {
    return TradeListState(
      status: status ?? this.status,
      trades: trades ?? this.trades,
    );
  }

  @override
  List<Object?> get props => [status, trades];
}
