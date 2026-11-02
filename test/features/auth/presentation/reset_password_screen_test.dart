import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/auth/data/repositories/auth_repository.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/auth/presentation/screens/reset_password_screen.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest({String? initialToken}) {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        home: ResetPasswordScreen(initialToken: initialToken),
      ),
    );
  }

  testWidgets('ResetPasswordScreen validates and submits new password', (tester) async {
    when(() => mockAuthRepository.resetPassword(
          token: 'token-abc-123',
          newPassword: 'NewSecurePassword1!',
        )).thenAnswer(
      (_) async => {
        'success': true,
        'message': 'Password has been reset successfully.',
      },
    );

    await tester.pumpWidget(createWidgetUnderTest(initialToken: 'token-abc-123'));
    await tester.pumpAndSettle();

    expect(find.text('Set New Password'), findsOneWidget);
    expect(find.text('token-abc-123'), findsOneWidget);
    expect(find.text('Update Password'), findsOneWidget);

    // Enter matching secure password
    final passwordFields = find.byType(TextFormField);
    // passwordFields[0] is token, [1] is new password, [2] is confirm password
    await tester.enterText(passwordFields.at(1), 'NewSecurePassword1!');
    await tester.enterText(passwordFields.at(2), 'NewSecurePassword1!');
    await tester.pumpAndSettle();

    // Tap Update Password
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.resetPassword(
          token: 'token-abc-123',
          newPassword: 'NewSecurePassword1!',
        )).called(1);
  });

  testWidgets('ResetPasswordScreen shows validation error if passwords do not match', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(initialToken: 'token-abc-123'));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(TextFormField);
    await tester.enterText(passwordFields.at(1), 'NewSecurePassword1!');
    await tester.enterText(passwordFields.at(2), 'DifferentPassword2@');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    verifyNever(() => mockAuthRepository.resetPassword(token: any(named: 'token'), newPassword: any(named: 'newPassword')));
  });
}
