import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/trade.dart';
import '../../domain/usecases/trade_usecases.dart';

part 'trade_list_event.dart';
part 'trade_list_state.dart';

class TradeListBloc extends Bloc<TradeListEvent, TradeListState> {
  TradeListBloc({required this._getTrades, required this._deleteTrade}) : super(const TradeListState()) {
    on<TradeListLoadRequested>(_onLoad);
    on<TradeDeleteRequested>(_onDelete);
  }

  final GetTrades _getTrades;
  final DeleteTrade _deleteTrade;

  Future<void> _onLoad(TradeListLoadRequested event, Emitter<TradeListState> emit) async {
    emit(state.copyWith(status: TradeListStatus.loading));
    try {
      final trades = await _getTrades(const NoParams());
      emit(state.copyWith(status: TradeListStatus.loaded, trades: trades));
    } catch (_) {
      emit(state.copyWith(status: TradeListStatus.error));
    }
  }

  Future<void> _onDelete(TradeDeleteRequested event, Emitter<TradeListState> emit) async {
    await _deleteTrade(event.id);
    add(const TradeListLoadRequested());
  }
}
