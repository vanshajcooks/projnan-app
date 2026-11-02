import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthResponseData {
  final UserModel user;
  final String token;
  final String? verificationToken;

  const AuthResponseData({
    required this.user,
    required this.token,
    this.verificationToken,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      verificationToken: json['verificationToken'] as String?,
    );
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

abstract class IAuthRemoteDataSource {
  Future<AuthResponseData> login({
    required String email,
    required String password,
  });

  Future<AuthResponseData> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    String? classCode,
  });

  Future<UserModel> getCurrentUser();

  Future<void> logout();

  Future<Map<String, dynamic>> forgotPassword(String email);

  Future<Map<String, dynamic>> resendVerification();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  @override
  Future<AuthResponseData> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      return _parseAuthResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthResponseData> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    String? classCode,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'username': username.trim().toLowerCase().replaceAll(RegExp(r'^@'), ''),
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': role,
          if (classCode != null && classCode.trim().isNotEmpty)
            'classCode': classCode.trim().toUpperCase(),
        },
      );

      return _parseAuthResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw const AuthException('Invalid user data received from server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
    } catch (_) {
      // Ignore network errors on logout to allow local session clearance
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': true, 'message': 'Password reset instructions have been sent.'};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> resendVerification() async {
    try {
      final response = await apiClient.post('/auth/resend-verification');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'success': true, 'message': 'Verification link sent to your email.'};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AuthResponseData _parseAuthResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['success'] == true && responseData['data'] != null) {
        return AuthResponseData.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      final msg = responseData['message'] as String? ?? 'Authentication failed';
      throw AuthException(msg);
    }
    throw const AuthException('Unexpected response from server');
  }

  AuthException _handleDioError(DioException error) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return AuthException(message, error.response?.statusCode);
        }
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AuthException('Connection timed out. Please check your internet or server.');
      case DioExceptionType.connectionError:
        return const AuthException('Unable to reach server. Make sure Probon backend is running on port 5000.');
      default:
        return AuthException(error.message ?? 'Network error occurred', error.response?.statusCode);
    }
  }
}
