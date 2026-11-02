import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/network/api_client.dart';
import 'package:probon_app/core/network/auth_interceptor.dart';
import 'package:probon_app/core/storage/token_storage.dart';

class MockTokenStorage implements ITokenStorage {
  String? token;

  MockTokenStorage({this.token});

  @override
  Future<void> saveToken(String token) async => this.token = token;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<bool> hasToken() async => token != null;
}

class SpyErrorHandler extends ErrorInterceptorHandler {
  DioException? interceptedError;

  @override
  void next(DioException err) {
    interceptedError = err;
  }
}

class SpyRequestHandler extends RequestInterceptorHandler {
  RequestOptions? interceptedOptions;

  @override
  void next(RequestOptions options) {
    interceptedOptions = options;
  }
}

void main() {
  group('ApiClient and AuthInterceptor Tests', () {
    test('AuthInterceptor attaches Bearer token when available', () async {
      final storage = MockTokenStorage(token: 'mock_jwt_token_xyz');
      final interceptor = AuthInterceptor(tokenStorage: storage);

      final options = RequestOptions(path: '/api/test');
      final handler = SpyRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer mock_jwt_token_xyz');
      expect(options.headers['Accept'], 'application/json');
      expect(handler.interceptedOptions, options);
    });

    test('AuthInterceptor omits Authorization header when token is null', () async {
      final storage = MockTokenStorage(token: null);
      final interceptor = AuthInterceptor(tokenStorage: storage);

      final options = RequestOptions(path: '/api/test');
      final handler = SpyRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), false);
      expect(handler.interceptedOptions, options);
    });

    test('AuthInterceptor calls onUnauthorized callback on 401 error', () async {
      bool unauthorizedCalled = false;
      final storage = MockTokenStorage(token: 'expired_token');
      final interceptor = AuthInterceptor(
        tokenStorage: storage,
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/protected'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/protected'),
          statusCode: 401,
        ),
      );

      final handler = SpyErrorHandler();
      interceptor.onError(dioError, handler);

      expect(unauthorizedCalled, true);
      expect(handler.interceptedError, dioError);
    });

    test('ApiClient initializes with custom base URL and headers', () {
      final storage = MockTokenStorage();
      final client = ApiClient(
        customTokenStorage: storage,
        baseUrl: 'http://test.api.probon.local/api',
      );

      expect(client.dio.options.baseUrl, 'http://test.api.probon.local/api');
      expect(client.dio.options.headers['Accept'], 'application/json');
    });
  });
}
