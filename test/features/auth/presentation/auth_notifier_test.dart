import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:probon_app/features/auth/data/models/user_model.dart';
import 'package:probon_app/features/auth/data/repositories/auth_repository.dart';
import 'package:probon_app/features/auth/presentation/controllers/auth_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  const testUser = UserModel(
    id: 1,
    name: 'Aryan Patel',
    username: 'aryan',
    email: 'aryan@example.com',
    role: 'student',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier Tests', () {
    test('initial state has AuthStatus.initial', () {
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.user, null);
      expect(state.isAuthenticated, false);
    });

    test('checkAuthStatus sets authenticated if user is returned', () async {
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => testUser);

      await container.read(authNotifierProvider.notifier).checkAuthStatus();
      final state = container.read(authNotifierProvider);

      expect(state.status, AuthStatus.authenticated);
      expect(state.user, testUser);
      expect(state.isAuthenticated, true);
    });

    test('checkAuthStatus sets unauthenticated if user is null', () async {
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      await container.read(authNotifierProvider.notifier).checkAuthStatus();
      final state = container.read(authNotifierProvider);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
    });

    test('login sets authenticated state on success', () async {
      when(() => mockRepository.login(
            email: 'aryan@example.com',
            password: 'Password123!',
          )).thenAnswer((_) async => testUser);

      final success = await container.read(authNotifierProvider.notifier).login(
            'aryan@example.com',
            'Password123!',
          );

      expect(success, true);
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, testUser);
      expect(state.errorMessage, null);
    });

    test('login sets error state on failure', () async {
      when(() => mockRepository.login(
            email: 'wrong@example.com',
            password: 'bad',
          )).thenThrow(const AuthException('Invalid email or password.'));

      final success = await container.read(authNotifierProvider.notifier).login(
            'wrong@example.com',
            'bad',
          );

      expect(success, false);
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid email or password.');
      expect(state.hasError, true);
    });

    test('clearError resets status to unauthenticated', () async {
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Failed'));

      await container.read(authNotifierProvider.notifier).login('a@b.com', 'c');
      expect(container.read(authNotifierProvider).hasError, true);

      container.read(authNotifierProvider.notifier).clearError();
      final state = container.read(authNotifierProvider);
      expect(state.hasError, false);
      expect(state.errorMessage, null);
      expect(state.status, AuthStatus.unauthenticated);
    });
  });
}
