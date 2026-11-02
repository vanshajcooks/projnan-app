import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    String? classCode,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> hasSavedToken();
  Future<Map<String, dynamic>> forgotPassword(String email);
  Future<Map<String, dynamic>> resendVerification();
}

class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final ITokenStorage tokenStorage;

  AuthRepository({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      email: email,
      password: password,
    );
    await tokenStorage.saveToken(result.token);
    return result.user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    String? classCode,
  }) async {
    final result = await remoteDataSource.register(
      name: name,
      username: username,
      email: email,
      password: password,
      role: role,
      classCode: classCode,
    );
    await tokenStorage.saveToken(result.token);
    return result.user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final hasToken = await tokenStorage.hasToken();
    if (!hasToken) return null;

    try {
      return await remoteDataSource.getCurrentUser();
    } catch (_) {
      await tokenStorage.deleteToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await tokenStorage.deleteToken();
  }

  @override
  Future<bool> hasSavedToken() async {
    return await tokenStorage.hasToken();
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<Map<String, dynamic>> resendVerification() async {
    return await remoteDataSource.resendVerification();
  }
}
