import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/theme/app_theme.dart';
import 'package:probon_app/core/utils/app_notifications.dart';

void main() {
  Widget buildTestableApp(void Function(BuildContext) trigger) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => trigger(context),
            child: const Text('Show Toast'),
          ),
        ),
      ),
    );
  }

  group('AppToast Tests', () {
    testWidgets('showSuccess renders SnackBar with success message', (tester) async {
      await tester.pumpWidget(
        buildTestableApp((ctx) => AppToast.showSuccess(ctx, 'Operation successful!')),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump(); // Start SnackBar animation

      expect(find.text('Operation successful!'), findsOneWidget);
    });

    testWidgets('showError renders SnackBar with error message', (tester) async {
      await tester.pumpWidget(
        buildTestableApp((ctx) => AppToast.showError(ctx, 'Something went wrong.')),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      expect(find.text('Something went wrong.'), findsOneWidget);
    });

    testWidgets('showInfo renders SnackBar with info message', (tester) async {
      await tester.pumpWidget(
        buildTestableApp((ctx) => AppToast.showInfo(ctx, 'Heads up: info notice.')),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      expect(find.text('Heads up: info notice.'), findsOneWidget);
    });
  });
}
