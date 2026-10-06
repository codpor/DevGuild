import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/main.dart';
import 'package:devguild/router/app_router.dart';
import 'package:devguild/providers/auth_provider.dart';
import 'package:devguild/providers/ticket_provider.dart';
import 'package:devguild/providers/project_provider.dart';
import 'package:devguild/providers/role_provider.dart';
import 'package:devguild/repositories/mock_repository.dart';

void main() {
  testWidgets('DevGuild app smoke test', (WidgetTester tester) async {
    final repo = MockRepository();
    final authProvider = AuthProvider(repo);
    final ticketProvider = TicketProvider(repo, authProvider);
    final projectProvider = ProjectProvider(repo, authProvider);
    final roleProvider = RoleProvider(repo, authProvider);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: ticketProvider),
          ChangeNotifierProvider.value(value: projectProvider),
          ChangeNotifierProvider.value(value: roleProvider),
        ],
        child: DevGuildApp(router: AppRouter.createRouter(authProvider)),
      ),
    );

    // Verify login screen renders
    expect(find.text('DevGuild'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
  });
}
