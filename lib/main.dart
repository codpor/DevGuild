import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'constants/app_strings.dart';
import 'repositories/mock_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/project_provider.dart';
import 'providers/role_provider.dart';
import 'router/app_router.dart';

void main() {
  // ── Inisialisasi Repository (data layer)
  final repository = MockRepository();

  // ── Inisialisasi Providers (business logic layer)
  final authProvider = AuthProvider(repository);
  final ticketProvider = TicketProvider(repository, authProvider);
  final projectProvider = ProjectProvider(repository, authProvider);
  final roleProvider = RoleProvider(repository, authProvider);

  // ── Inisialisasi Router
  final router = AppRouter.createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: ticketProvider),
        ChangeNotifierProvider.value(value: projectProvider),
        ChangeNotifierProvider.value(value: roleProvider),
      ],
      child: DevGuildApp(router: router),
    ),
  );
}

class DevGuildApp extends StatelessWidget {
  final GoRouter router;
  const DevGuildApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
