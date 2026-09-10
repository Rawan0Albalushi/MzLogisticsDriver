import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/json_readers.dart';
import '../../../core/auth/token_storage.dart';
import '../../../shared/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  AuthRepository(this._client, this._tokens);

  final ApiClient _client;
  final TokenStorage _tokens;

  Future<User> login(String email, String password) async {
    final envelope = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      parse: (raw) => readMap(raw) ?? {},
    );
    final token = readString(envelope.data['token']);
    if (token == null) {
      throw StateError('Missing token');
    }
    await _tokens.write(token);
    return User.fromJson(readMap(envelope.data['user']) ?? {});
  }

  Future<User> me() async {
    final envelope = await _client.get<User>(
      ApiEndpoints.me,
      parse: (raw) => User.fromJson(readMap(raw) ?? {}),
    );
    return envelope.data;
  }

  Future<void> updateLocale(String locale) {
    return _client.patch<User>(
      ApiEndpoints.me,
      data: {'locale': locale},
      parse: (raw) => User.fromJson(readMap(raw) ?? {}),
    );
  }

  Future<void> logout() async {
    try {
      await _client.post<void>(
        ApiEndpoints.logout,
        parse: (_) {},
      );
    } finally {
      await _tokens.clear();
    }
  }
}
