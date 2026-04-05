import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/cars/presentation/car_dashboard_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/auth/presentation/server_setup_page.dart';

import '../core/storage/secure_storage.dart';

final serverUrlStateProvider = FutureProvider<String?>((ref) async {
  return await const SecureStorageService().getServerUrl();
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final serverUrlState = ref.watch(serverUrlStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      if (authState == AuthState.initial) {
        return null; // Don't redirect until we know the state
      }

      final isAuthenticated = authState == AuthState.authenticated;
      final isGoingToAuthPaths = state.matchedLocation == '/signin' || 
                                 state.matchedLocation == '/signup' ||
                                 state.matchedLocation == '/server-setup';
      final isSplash = state.matchedLocation == '/splash';
      final isServerSetup = state.matchedLocation == '/server-setup';

      if (isSplash) return null;

      // Handle server URL resolution first
      if (serverUrlState.isLoading) return null; 
      final hasServerUrl = serverUrlState.value != null;
      if (!hasServerUrl && !isServerSetup && !isAuthenticated) {
        return '/server-setup';
      }

      if (!isAuthenticated && !isGoingToAuthPaths) {
        return hasServerUrl ? '/signin' : '/server-setup';
      }

      if (isAuthenticated && isGoingToAuthPaths) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/server-setup',
        builder: (BuildContext context, GoRouterState state) => const ServerSetupPage(),
      ),
      GoRoute(
        path: '/signin',
        builder: (BuildContext context, GoRouterState state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) => const SplashPage(),
      ),
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/car/:id',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return CarDashboardPage(carId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) => const ProfilePage(),
      ),
    ],
  );
});
