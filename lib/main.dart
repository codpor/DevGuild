import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'theme.dart';
import 'constants/app_strings.dart';
import 'repositories/local_repository.dart';
import 'widgets/storage_banner.dart';
import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/project_provider.dart';
import 'providers/role_provider.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DevGuildBootstrap());
}

class DevGuildBootstrap extends StatefulWidget {
  final Future<LocalRepository> Function()? openRepository;
  const DevGuildBootstrap({super.key, this.openRepository});

  @override
  State<DevGuildBootstrap> createState() => _DevGuildBootstrapState();
}

class _DevGuildBootstrapState extends State<DevGuildBootstrap> {
  late Future<LocalRepository> _opening;

  @override
  void initState() {
    super.initState();
    _open();
  }

  void _open() {
    _opening = (widget.openRepository ?? LocalRepository.open)();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LocalRepository>(
    future: _opening,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return _AppSession(repository: snapshot.requireData);
      }
      return MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Data lokal tidak dapat dibuka.'),
                        const SizedBox(height: 12),
                        const Text(
                          'Periksa penyimpanan perangkat atau izin browser. Data yang ada tetap dipertahankan.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(_open),
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

class _AppSession extends StatefulWidget {
  final LocalRepository repository;
  const _AppSession({required this.repository});
  @override
  State<_AppSession> createState() => _AppSessionState();
}

class _AppSessionState extends State<_AppSession> {
  late final AuthProvider _auth;
  late final TicketProvider _tickets;
  late final ProjectProvider _projects;
  late final RoleProvider _roles;
  late final GoRouter _router;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository;
    _auth = AuthProvider(repository);
    _tickets = TicketProvider(repository, _auth);
    _projects = ProjectProvider(repository, _auth);
    _roles = RoleProvider(repository, _auth);
    _router = AppRouter.createRouter(_auth);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state != AppLifecycleState.resumed) {
          unawaited(repository.flush().catchError((Object _) {}));
        }
      },
      onExitRequested: () async {
        try {
          await repository.flush();
          return AppExitResponse.exit;
        } catch (_) {
          return AppExitResponse.cancel;
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    _roles.dispose();
    _projects.dispose();
    _tickets.dispose();
    _auth.dispose();
    unawaited(widget.repository.close().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _auth),
      ChangeNotifierProvider.value(value: _tickets),
      ChangeNotifierProvider.value(value: _projects),
      ChangeNotifierProvider.value(value: _roles),
    ],
    child: DevGuildApp(router: _router, repository: widget.repository),
  );
}

class DevGuildApp extends StatelessWidget {
  final GoRouter router;
  final LocalRepository? repository;
  const DevGuildApp({super.key, required this.router, this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: repository == null
          ? null
          : (context, child) =>
                StorageBanner(repository: repository!, child: child!),
    );
  }
}
