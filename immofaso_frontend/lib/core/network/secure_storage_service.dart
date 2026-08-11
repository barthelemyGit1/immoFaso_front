import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Encapsule l'accès au stockage sécurisé (Keychain iOS / Keystore Android)
/// pour tout ce qui touche à la session utilisateur.
class SecureStorageService {
  SecureStorageService()
    : _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  final FlutterSecureStorage _storage;

  static const _keyCachedUser = 'immofaso_cached_user';

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken),
      _storage.write(key: AppConstants.keyRefreshToken, value: refreshToken),
      _storage.write(key: AppConstants.keyUserId, value: userId),
      _storage.write(key: AppConstants.keyUserRole, value: role),
    ]);
  }

  /// Cache le profil utilisateur en local (JSON). Utilisé notamment en
  /// mode mock pour restaurer la session sans appel réseau réel.
  Future<void> saveCachedUserJson(Map<String, dynamic> userJson) =>
      _storage.write(key: _keyCachedUser, value: jsonEncode(userJson));

  Future<Map<String, dynamic>?> readCachedUserJson() async {
    final raw = await _storage.read(key: _keyCachedUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<String?> get accessToken =>
      _storage.read(key: AppConstants.keyAccessToken);

  Future<String?> get refreshToken =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<String?> get userRole => _storage.read(key: AppConstants.keyUserRole);

  Future<String?> get userId => _storage.read(key: AppConstants.keyUserId);

  Future<void> updateAccessToken(String accessToken) =>
      _storage.write(key: AppConstants.keyAccessToken, value: accessToken);

  Future<bool> hasValidSession() async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: AppConstants.keyAccessToken),
      _storage.delete(key: AppConstants.keyRefreshToken),
      _storage.delete(key: AppConstants.keyUserId),
      _storage.delete(key: AppConstants.keyUserRole),
      _storage.delete(key: _keyCachedUser),
    ]);
  }
}
