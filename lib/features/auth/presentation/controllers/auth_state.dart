import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/user_model.dart';

// Storage Provider
final tokenStorageProvider = Provider<ITokenStorage>((ref) {
  return SecureTokenStorage();
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(
    customTokenStorage: storage,
    onUnauthorized: () {
      ref.read(authNotifierProvider.notifier).handleUnauthorized();
    },
  );
});

// Auth State Definition
enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth State Controller
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final storage = ref.read(tokenStorageProvider);
      final hasToken = await storage.hasToken();

      if (!hasToken) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final client = ref.read(apiClientProvider);
      final response = await client.get('/auth/me');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final user = UserModel.fromJson(data['data'] as Map<String, dynamic>);
          state = AuthState(status: AuthStatus.authenticated, user: user);
          return;
        }
      }

      // If token invalid, clear and set unauthenticated
      await storage.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (_) {
      // Offline or network error: if token exists, we can still fall back or show error
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void setUserSession(UserModel user, String token) async {
    final storage = ref.read(tokenStorageProvider);
    await storage.saveToken(token);
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/auth/logout');
    } catch (_) {
      // Ignore network failure on logout
    } finally {
      await storage.deleteToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void handleUnauthorized() async {
    final storage = ref.read(tokenStorageProvider);
    await storage.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
