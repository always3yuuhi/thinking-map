import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's Claude API key in the platform keystore/keychain —
/// never in the SQLite DB or plain preferences (spec 4 プライバシー要件).
class ApiKeyStorage {
  ApiKeyStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _claudeApiKeyKey = 'claude_api_key';

  Future<String?> readClaudeApiKey() => _storage.read(key: _claudeApiKeyKey);

  Future<void> writeClaudeApiKey(String value) =>
      _storage.write(key: _claudeApiKeyKey, value: value);

  Future<void> deleteClaudeApiKey() => _storage.delete(key: _claudeApiKeyKey);
}
