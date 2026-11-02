import 'package:flutter_test/flutter_test.dart';
import 'package:probon_app/core/storage/token_storage.dart';

class InMemoryTokenStorage implements ITokenStorage {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<bool> hasToken() async {
    return _token != null && _token!.isNotEmpty;
  }
}

void main() {
  group('TokenStorage Tests', () {
    late ITokenStorage storage;

    setUp(() {
      storage = InMemoryTokenStorage();
    });

    test('initial state has no token', () async {
      expect(await storage.hasToken(), false);
      expect(await storage.getToken(), null);
    });

    test('saveToken saves token and hasToken returns true', () async {
      await storage.saveToken('jwt_test_token_123');
      expect(await storage.hasToken(), true);
      expect(await storage.getToken(), 'jwt_test_token_123');
    });

    test('deleteToken clears stored token', () async {
      await storage.saveToken('jwt_test_token_123');
      await storage.deleteToken();
      expect(await storage.hasToken(), false);
      expect(await storage.getToken(), null);
    });
  });
}
