import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:probon_app/core/network/api_client.dart';
import 'package:probon_app/features/auth/data/datasources/auth_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSource(apiClient: mockApiClient);
  });

  group('AuthRemoteDataSource Tests', () {
    final validLoginJson = {
      'success': true,
      'message': 'Signed in successfully.',
      'data': {
        'user': {
          'id': 1,
          'name': 'Test User',
          'username': 'testuser',
          'email': 'test@example.com',
          'role': 'student',
          'email_verified': 1,
        },
        'token': 'jwt_token_abc_123',
      },
    };

    test('login returns AuthResponseData when backend response is successful', () async {
      when(() => mockApiClient.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 200,
          data: validLoginJson,
        ),
      );

      final result = await dataSource.login(
        email: 'test@example.com',
        password: 'Password123!',
      );

      expect(result.token, 'jwt_token_abc_123');
      expect(result.user.email, 'test@example.com');
      expect(result.user.name, 'Test User');
    });

    test('login throws AuthException when server returns 401 with error message', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
          data: {
            'success': false,
            'message': 'Invalid email or password.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockApiClient.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenThrow(dioError);

      expect(
        () => dataSource.login(
          email: 'wrong@example.com',
          password: 'Password123!',
        ),
        throwsA(isA<AuthException>().having((e) => e.message, 'message', 'Invalid email or password.')),
      );
    });

    test('register parses successful account creation data', () async {
      final validRegisterJson = {
        'success': true,
        'message': 'Account created successfully.',
        'data': {
          'user': {
            'id': 2,
            'name': 'Teacher John',
            'username': 'teacher_john',
            'email': 'john@school.edu',
            'role': 'teacher',
            'email_verified': 0,
          },
          'token': 'jwt_teacher_token_456',
        },
      };

      when(() => mockApiClient.post(
            '/auth/register',
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/register'),
          statusCode: 201,
          data: validRegisterJson,
        ),
      );

      final result = await dataSource.register(
        name: 'Teacher John',
        username: 'teacher_john',
        email: 'john@school.edu',
        password: 'Password123!',
        role: 'teacher',
      );

      expect(result.user.isTeacher, true);
      expect(result.token, 'jwt_teacher_token_456');
    });
  });
}
