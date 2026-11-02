import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    // If unauthenticated and trying to access dashboard/protected routes -> redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // If authenticated and on login/register -> redirect to dashboard
    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/dashboard',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final tabIndex = int.tryParse(tabParam ?? '') ?? 0;
          return DashboardScreen(initialTab: tabIndex);
        },
      ),
      GoRoute(
        path: '/projects',
        redirect: (context, state) => '/dashboard?tab=1',
      ),
      GoRoute(
        path: '/tasks',
        redirect: (context, state) => '/dashboard?tab=2',
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) => '/dashboard?tab=3',
      ),
    ],
  );
});
