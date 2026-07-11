import '../di/injection_container.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/trade/presentation/bloc/trade_list_bloc.dart';

void refreshTradeScreens() {
  sl<DashboardBloc>().add(const DashboardLoadRequested());
  sl<TradeListBloc>().add(const TradeListLoadRequested());
}
