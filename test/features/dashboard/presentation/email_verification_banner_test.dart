import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/auth/data/repositories/auth_repository.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/features/dashboard/presentation/widgets/email_verification_banner.dart';

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
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: EmailVerificationBanner(),
          ),
        ),
      ),
    );
  }

  testWidgets('EmailVerificationBanner renders and resends verification email', (tester) async {
    when(() => mockAuthRepository.resendVerification()).thenAnswer(
      (_) async => {
        'success': true,
        'message': 'Verification link sent to your email address.',
      },
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Verify Your Email'), findsOneWidget);
    expect(find.text('Resend Link'), findsOneWidget);

    await tester.tap(find.text('Resend Link'));
    await tester.pump(); // Start async work
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.resendVerification()).called(1);
    expect(find.text('Verification link sent to your email address.'), findsOneWidget);

    // Dismiss banner
    expect(find.text('Dismiss'), findsOneWidget);
    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.text('Verify Your Email'), findsNothing);
  });
}
