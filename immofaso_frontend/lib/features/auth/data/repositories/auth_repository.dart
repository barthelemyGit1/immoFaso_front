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
/// Correspond aux routes Laravel de `routes/auth.php` (préfixées `/v1`,
/// elles-mêmes sous le préfixe `/api` de `routes/api.php`) :
///   POST /register
///   POST /verify-otp
///   POST /resend-otp
///   POST /password-reset
///   POST /password-reset/confirm
///   POST /login
///   GET  /users/me           (routes/api.php, protégée par auth:sanctum)
class AuthRepository {
  AuthRepository({required ApiClient apiClient, required SecureStorageService storage})
      : _api = apiClient,
        _storage = storage;

  final ApiClient _api;
  final SecureStorageService _storage;

  /// Étape 1 de l'inscription : création du compte (non vérifié) + envoi OTP.
  /// Le rôle choisi ici détermine le parcours (locataire ou propriétaire) ;
  /// le rôle admin n'est jamais créé via cet écran public.
  Future<String?> register({
    required String nom,
    required String prenom,
    required String telephone,
    required String password,
    required UserRole role,
    String? email,
  }) async {
    try {
      final response = await _api.raw.post('/register', data: {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'password': password,
        'password_confirmation': password,
        'role': role.apiValue,
        'email': email,
      });
      return _extractOtpCode(response.data as Map<String, dynamic>);
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
      final response = await _api.raw.post('/verify-otp', data: {
        'telephone': telephone,
        'otp': otpCode,
      });
      return _persistAndReturnSession(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<String?> resendOtp({required String telephone}) async {
    try {
      final response = await _api.raw.post('/resend-otp', data: {'telephone': telephone});
      return _extractOtpCode(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  /// Le champ `otp.password` n'est présent que si le back tourne en
  /// environnement local (cf. UtilisateurController::store / ResendOtpController).
  String? _extractOtpCode(Map<String, dynamic> responseBody) {
    final data = responseBody['data'] as Map<String, dynamic>?;
    final otp = data?['otp'] as Map<String, dynamic>?;
    return otp?['password'] as String?;
  }

  /// Connexion par téléphone + mot de passe.
  Future<AuthResult> login({
    required String telephone,
    required String password,
  }) async {
    /*if (AppConstants.useMockAuth) {
      return _mockLogin(telephone: telephone);
    }*/
    try {
      final response = await _api.raw.post('/login', data: {
        'telephone': telephone,
        'password': password,
      });
      return _persistAndReturnSession(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }


  Future<String?> forgotPassword({required String telephone}) async {
    try {
      final response = await _api.raw.post('/password-reset', data: {'telephone': telephone});
      return _extractOtpCode(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> changerPassword({
    required String telephone,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await _api.raw.post('/password-reset/confirm', data: {
        'telephone': telephone,
        'otp': otpCode,
        'password': newPassword,
        'password_confirmation': newPassword,
      });
    } on DioException catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  Future<void> logout() async {
    if (!AppConstants.useMockAuth) {
      try {
        await _api.raw.post('/logout');
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
      final response = await _api.raw.get('/user/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<AuthResult> _persistAndReturnSession(Map<String, dynamic> responseBody) async {

    final data = responseBody['data'] as Map<String, dynamic>? ?? responseBody;
  
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    // 3. Extraire le token
    final accessToken = (data['token'] ?? data['accessToken'] ?? '') as String;

    // 4. Gestion sécurisée de refreshToken (mettre une chaîne vide si absent)
    final refreshToken = (data['refreshToken'] ?? data['refresh_token'] ?? '') as String;

    // 5. Sauvegarder la session
    await _storage.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
      role: user.role.apiValue,
    );

    return AuthResult(user: user, accessToken: accessToken, refreshToken: refreshToken);
  }
}