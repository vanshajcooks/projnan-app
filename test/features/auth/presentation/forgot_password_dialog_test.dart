import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/auth/data/repositories/auth_repository.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/auth/presentation/widgets/forgot_password_dialog.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ForgotPasswordDialog(initialEmail: 'reset.user@example.com'),
        ),
      ),
    );
  }

  testWidgets('ForgotPasswordDialog renders email and sends reset link successfully', (tester) async {
    when(() => mockAuthRepository.forgotPassword('reset.user@example.com')).thenAnswer(
      (_) async => {
        'success': true,
        'message': 'Password reset instructions sent.',
        'resetToken': 'mock-dev-token-12345',
      },
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('reset.user@example.com'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);

    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.forgotPassword('reset.user@example.com')).called(1);
    expect(find.text('Check Your Email'), findsOneWidget);
    expect(find.textContaining('mock-dev-token-12345'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });
}
