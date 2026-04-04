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

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      if (authState == AuthState.initial) {
        return null; // Don't redirect until we know the state
      }

      final isAuthenticated = authState == AuthState.authenticated;
      final isGoingToAuthPaths = state.matchedLocation == '/signin' || 
                                 state.matchedLocation == '/signup';

      if (!isAuthenticated && !isGoingToAuthPaths) {
        return '/signin';
      }

      if (isAuthenticated && isGoingToAuthPaths) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/signin',
        builder: (BuildContext context, GoRouterState state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) => const SignUpPage(),
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
