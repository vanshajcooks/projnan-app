import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:probon_app/core/storage/token_storage.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';
import 'package:probon_app/main.dart';

class TestTokenStorage implements ITokenStorage {
  @override
  Future<void> deleteToken() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<bool> hasToken() async => false;

  @override
  Future<void> saveToken(String token) async {}
}

void main() {
  testWidgets('ProbonApp initial launch renders Login screen for unauthenticated users', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(TestTokenStorage()),
        ],
        child: const ProbonApp(),
      ),
    );

    // Initial frame should render Welcome Back header, email, password, and sign in
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
  });
}
