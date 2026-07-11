import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/domain/usecases/settings_usecases.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/strategy/presentation/pages/strategies_page.dart';
import '../../features/trade/presentation/bloc/trade_form_bloc.dart';
import '../../features/trade/presentation/bloc/trade_list_bloc.dart';
import '../../features/trade/presentation/pages/trade_detail_page.dart';
import '../../features/trade/presentation/pages/trade_form_page.dart';
import '../../features/trade/presentation/pages/trade_list_page.dart';
import '../widgets/app_shell.dart';
import '../usecases/usecase.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SplashCubit>(),
            child: const SplashPage(),
          ),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
            child: const AuthPage(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<AuthBloc>()),
              BlocProvider.value(value: sl<DashboardBloc>()),
              BlocProvider.value(value: sl<TradeListBloc>()),
              BlocProvider(create: (_) => sl<SettingsCubit>()),
            ],
            child: AppShell(child: child),
          ),
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => _fadePage(state, const DashboardPage()),
            ),
            GoRoute(
              path: '/trades',
              pageBuilder: (context, state) => _fadePage(state, const TradeListPage()),
              routes: [
                GoRoute(
                  path: 'add',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => BlocProvider(
                    create: (_) => sl<TradeFormBloc>(),
                    child: const TradeFormPage(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      TradeDetailPage(tradeId: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                        create: (_) => sl<TradeFormBloc>(),
                        child: TradeFormPage(tradeId: state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _fadePage(state, const SettingsPage()),
              routes: [
                GoRoute(
                  path: 'strategies',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const StrategiesPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) =>
                          StrategyDetailPage(strategyId: state.pathParameters['id']!),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;
    if (location == '/' || location == '/auth') return null;

    final settings = await sl<GetSettings>()(const NoParams());
    if (!settings.isBiometricEnabled) return null;

    final isAuth = sl<IsAuthenticated>()();
    if (!isAuth && location != '/auth') {
      return '/auth';
    }
    return null;
  }
}
