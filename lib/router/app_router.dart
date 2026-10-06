// lib/router/app_router.dart
// Konfigurasi routing terpusat menggunakan go_router
// Menggantikan string-based routing dengan type-safe constants

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';

/// Konstanta route — menghindari typo string hardcode
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

class AppRouter {
  AppRouter._();

  /// Buat GoRouter dengan redirect guard berdasarkan auth state.
  /// [authProvider] digunakan sebagai refreshListenable agar router
  /// otomatis re-evaluate redirect saat auth state berubah.
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = authProvider.currentUser != null;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register;

        // Belum login tapi akses halaman selain auth → redirect ke login
        if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;

        // Sudah login tapi akses halaman auth → redirect ke home
        if (isLoggedIn && isAuthRoute) return AppRoutes.home;

        return null; // tidak perlu redirect
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }
}
