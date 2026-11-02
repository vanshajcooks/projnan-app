import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/storage/token_storage.dart';
import 'package:probon_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:probon_app/features/auth/data/models/user_model.dart';
import 'package:probon_app/features/auth/data/repositories/auth_repository.dart';

class MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}
class MockTokenStorage extends Mock implements ITokenStorage {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late MockTokenStorage mockStorage;
  late AuthRepository repository;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    mockStorage = MockTokenStorage();
    repository = AuthRepository(
      remoteDataSource: mockRemote,
      tokenStorage: mockStorage,
    );
  });

  const testUser = UserModel(
    id: 1,
    name: 'Test Student',
    username: 'teststudent',
    email: 'test@student.edu',
    role: 'student',
  );

  group('AuthRepository Tests', () {
    test('login saves token and returns user', () async {
      when(() => mockRemote.login(
            email: 'test@student.edu',
            password: 'Password123!',
          )).thenAnswer(
        (_) async => const AuthResponseData(
          user: testUser,
          token: 'saved_jwt_123',
        ),
      );
      when(() => mockStorage.saveToken('saved_jwt_123')).thenAnswer((_) async {});

      final user = await repository.login(
        email: 'test@student.edu',
        password: 'Password123!',
      );

      expect(user, testUser);
      verify(() => mockStorage.saveToken('saved_jwt_123')).called(1);
    });

    test('logout calls remote logout and deletes saved token', () async {
      when(() => mockRemote.logout()).thenAnswer((_) async {});
      when(() => mockStorage.deleteToken()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockRemote.logout()).called(1);
      verify(() => mockStorage.deleteToken()).called(1);
    });

    test('getCurrentUser returns null when no token is saved', () async {
      when(() => mockStorage.hasToken()).thenAnswer((_) async => false);

      final user = await repository.getCurrentUser();

      expect(user, null);
      verifyNever(() => mockRemote.getCurrentUser());
    });
  });
}
