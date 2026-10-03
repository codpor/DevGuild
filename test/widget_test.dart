import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:devguild/main.dart';
import 'package:devguild/providers/app_provider.dart';

void main() {
  testWidgets('DevGuild app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const DevGuildApp(),
      ),
    );

    // Verify login screen renders
    expect(find.text('DevGuild'), findsWidgets);
    expect(find.text('Masuk'), findsWidgets);
  });
}
