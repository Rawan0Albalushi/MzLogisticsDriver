import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read() {
    return _storage.read(key: AppConfig.tokenStorageKey);
  }

  Future<void> write(String token) {
    return _storage.write(key: AppConfig.tokenStorageKey, value: token);
  }

  Future<void> clear() {
    return _storage.delete(key: AppConfig.tokenStorageKey);
  }
}
