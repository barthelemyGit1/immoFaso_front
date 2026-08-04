import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/secure_storage_service.dart';
import '../models/user_model.dart';

/// Résultat d'une authentification réussie : token(s) + profil utilisateur.
class AuthResult {
  AuthResult({required this.user, required this.accessToken, required this.refreshToken});
  final UserModel user;
  final String accessToken;
  final String refreshToken;
}

/// Regroupe tous les appels réseau liés à l'authentification.
/// Correspond aux endpoints CA-AUTH-xx du contrat API :
///   POST /auth/register
///   POST /auth/otp/verify
///   POST /auth/otp/resend
///   POST /auth/login
///   POST /auth/refresh
///   POST /auth/forgot-password
///   POST /auth/reset-password
///   POST /auth/logout
class AuthRepository {
  AuthRepository({required ApiClient apiClient, required SecureStorageService storage})
      : _api = apiClient,
        _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  /// Étape 1 de l'inscription : création du compte (non vérifié) + envoi OTP.
  /// Le rôle choisi ici détermine le parcours (locataire ou propriétaire) ;
  /// le rôle admin n'est jamais créé via cet écran public.
  Future<void> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String password,
    required UserRole role,
    String? email,
  }) async {
    try {
      await _api.raw.post('/auth/register', data: {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'password': password,
        'role': role.apiValue,
        if (email != null && email.isNotEmpty) 'email': email,
      });
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Étape 2 : vérification du code OTP reçu par SMS.
  /// Renvoie directement une session valide (l'utilisateur est connecté
  /// automatiquement après vérification), conformément au flux du
  /// diagramme de séquence "Inscription OTP".
  Future<AuthResult> verifyOtp({
    required String telephone,
    required String otpCode,
  }) async {
    try {
      final response = await _api.raw.post('/auth/otp/verify', data: {
        'telephone': telephone,
        'code': otpCode,
      });
      return _persistAndReturnSession(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> resendOtp({required String telephone}) async {
    try {
      await _api.raw.post('/auth/otp/resend', data: {'telephone': telephone});
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Connexion par téléphone + mot de passe.
  Future<AuthResult> login({
    required String telephone,
    required String password,
  }) async {
    if (AppConstants.useMockAuth) {
      return _mockLogin(telephone: telephone);
    }
    try {
      final response = await _api.raw.post('/auth/login', data: {
        'telephone': telephone,
        'password': password,
      });
      return _persistAndReturnSession(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// MODE MOCK : simule une connexion réussie en tant que locataire, sans
  /// aucun appel réseau. Permet de continuer à construire les écrans
  /// (dashboard locataire, etc.) avant que le back-end soit disponible.
  /// ⚠️ À retirer quand `AppConstants.useMockAuth` repasse à `false`.
  Future<AuthResult> _mockLogin({required String telephone}) async {
    await Future.delayed(const Duration(milliseconds: 400)); // simule la latence réseau
    final user = UserModel.demo(UserRole.locataire);

    await _storage.saveSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      userId: user.id,
      role: user.role.apiValue,
    );
    await _storage.saveCachedUserJson(user.toJson());

    return AuthResult(user: user, accessToken: 'mock-access-token', refreshToken: 'mock-refresh-token');
  }

  Future<void> forgotPassword({required String telephone}) async {
    try {
      await _api.raw.post('/auth/forgot-password', data: {'telephone': telephone});
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> resetPassword({
    required String telephone,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await _api.raw.post('/auth/reset-password', data: {
        'telephone': telephone,
        'code': otpCode,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> logout() async {
    if (!AppConstants.useMockAuth) {
      try {
        await _api.raw.post('/auth/logout');
      } on DioException {
        // Non bloquant : on nettoie la session locale même si l'appel échoue.
      }
    }
    await _storage.clearSession();
  }

  /// Restaure la session locale au démarrage de l'app (auto-login).
  Future<UserModel?> restoreSession() async {
    final hasSession = await _storage.hasValidSession();
    if (!hasSession) return null;

    if (AppConstants.useMockAuth) {
      final cached = await _storage.readCachedUserJson();
      return cached != null ? UserModel.fromJson(cached) : null;
    }

    try {
      final response = await _api.raw.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<AuthResult> _persistAndReturnSession(Map<String, dynamic> data) async {
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _storage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
      role: user.role.apiValue,
    );

    return AuthResult(user: user, accessToken: accessToken, refreshToken: refreshToken);
  }
}