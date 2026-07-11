import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../usecases/usecase.dart';
import '../services/notification_service.dart';
import '../../features/auth/data/datasources/local_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/settings/data/datasources/hive_settings_datasource.dart';
import '../../features/settings/data/models/settings_model.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/data/services/data_export_service.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/settings_usecases.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/strategy/data/datasources/hive_strategy_datasource.dart';
import '../../features/strategy/data/models/strategy_model.dart';
import '../../features/strategy/data/repositories/strategy_repository_impl.dart';
import '../../features/strategy/domain/repositories/strategy_repository.dart';
import '../../features/strategy/domain/usecases/strategy_usecases.dart';
import '../../features/trade/data/datasources/hive_trade_datasource.dart';
import '../../features/trade/data/models/trade_model.dart';
import '../../features/trade/data/repositories/trade_repository_impl.dart';
import '../../features/trade/domain/repositories/trade_repository.dart';
import '../../features/trade/domain/usecases/trade_usecases.dart';
import '../../features/trade/presentation/bloc/trade_form_bloc.dart';
import '../../features/trade/presentation/bloc/trade_list_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TradeModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StrategyModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SettingsModelAdapter());
  }

  // Core services
  sl.registerLazySingleton<NotificationService>(NotificationService.new);

  // Auth
  sl.registerLazySingleton(LocalAuthentication.new);
  sl.registerLazySingleton(() => LocalAuthDatasource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => Authenticate(sl()));
  sl.registerLazySingleton(() => CheckBiometricAvailability(sl()));
  sl.registerLazySingleton(() => IsAuthenticated(sl()));
  sl.registerLazySingleton(() => SetAuthenticated(sl()));
  sl.registerLazySingleton(() => ResetAuthSession(sl()));
  sl.registerFactory(
    () => AuthBloc(
      authenticate: sl(),
      checkBiometricAvailability: sl(),
      setAuthenticated: sl(),
    ),
  );

  // Trade
  sl.registerLazySingleton(HiveTradeDatasource.new);
  sl.registerLazySingleton<TradeRepository>(() => TradeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetTrades(sl()));
  sl.registerLazySingleton(() => GetTradeById(sl()));
  sl.registerLazySingleton(() => AddTrade(sl()));
  sl.registerLazySingleton(() => UpdateTrade(sl()));
  sl.registerLazySingleton(() => DeleteTrade(sl()));
  sl.registerLazySingleton(() => GetOpenTrades(sl()));
  sl.registerLazySingleton(() => TradeListBloc(getTrades: sl(), deleteTrade: sl()));
  sl.registerFactory(
    () => TradeFormBloc(
      addTrade: sl(),
      updateTrade: sl(),
      getTradeById: sl(),
      getActiveStrategies: sl(),
      getSettings: sl(),
    ),
  );

  // Strategy
  sl.registerLazySingleton(HiveStrategyDatasource.new);
  sl.registerLazySingleton<StrategyRepository>(() => StrategyRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetStrategies(sl()));
  sl.registerLazySingleton(() => GetActiveStrategies(sl()));
  sl.registerLazySingleton(() => GetStrategyById(sl()));
  sl.registerLazySingleton(() => AddStrategy(sl()));
  sl.registerLazySingleton(() => UpdateStrategy(sl()));
  sl.registerLazySingleton(() => ArchiveStrategy(sl()));

  // Settings
  sl.registerLazySingleton(HiveSettingsDatasource.new);
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateSettings(sl()));
  sl.registerLazySingleton(
    () => DataExportService(
      tradeRepository: sl(),
      strategyRepository: sl(),
      settingsRepository: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => ClearAllData(
      tradeRepository: sl(),
      strategyRepository: sl(),
      settingsRepository: sl(),
    ),
  );
  sl.registerFactory(
    () => SettingsCubit(
      getSettings: sl(),
      updateSettings: sl(),
      exportService: sl(),
      clearAllData: sl(),
    ),
  );

  // Dashboard
  sl.registerLazySingleton(
    () => DashboardBloc(
      getTrades: sl(),
      getOpenTrades: sl(),
      getStrategies: sl(),
    ),
  );

  // Splash
  sl.registerFactory(
    () => SplashCubit(
      getSettings: sl(),
      resetAuthSession: sl(),
    ),
  );
}

Future<void> checkTradeReminder() async {
  final settings = await sl<GetSettings>()(const NoParams());
  if (!settings.isReminderEnabled) return;

  final trades = await sl<GetTrades>()(const NoParams());
  if (trades.isEmpty) {
    await sl<NotificationService>().showTradeReminder();
    return;
  }

  final latest = trades.map((t) => t.entryDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
  if (DateTime.now().difference(latest).inHours >= 24) {
    await sl<NotificationService>().showTradeReminder();
  }
}
