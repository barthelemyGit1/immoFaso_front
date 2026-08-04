class AppConstants {
  AppConstants._();

  static const String appName = 'ImmoFaso';

  /// MODE DÉVELOPPEMENT FRONT SEUL : quand `true`, les écrans d'auth ne
  /// font aucun appel réseau réel et simulent directement une session
  /// (utile tant que le back-end Node.js n'est pas branché).
  /// Repasser à `false` avant de connecter le vrai back-end.
  static const bool useMockAuth = true;

  // Idéalement injecté via --dart-define plutôt qu'en dur ici.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.immofaso.bf/v1',
  );

  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://api.immofaso.bf',
  );

  // Stockage sécurisé - clés
  static const String keyAccessToken = 'immofaso_access_token';
  static const String keyRefreshToken = 'immofaso_refresh_token';
  static const String keyUserRole = 'immofaso_user_role';
  static const String keyUserId = 'immofaso_user_id';
  static const String _keyCachedUser = 'immofaso_cached_user';

  // OTP
  static const int otpLength = 6;
  static const int otpResendDelaySeconds = 60;

  // Timeouts réseau
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

/// Rôles utilisateur — doit rester synchronisé avec l'enum UTILISATEUR.role
/// côté back-end (cf. document de conception).
enum UserRole{locataire, proprietaire, admin}

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
    UserRole.locataire => 'LOCATAIRE',
    UserRole.proprietaire => 'PROPRIETAIRE',
    UserRole.admin => 'ADMIN',
  };

  static UserRole fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'PROPRIETAIRE':
        return UserRole.proprietaire;
      case 'ADMIN':
        return UserRole.admin;
      case 'LOCATAIRE':
      default:
        return UserRole.locataire;
    }
  }
}