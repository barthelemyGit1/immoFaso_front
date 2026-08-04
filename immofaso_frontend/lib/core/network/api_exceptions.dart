/// Exception métier normalisée pour toute erreur venant de l'API.
/// Les écrans n'ont besoin de connaître que `message` (déjà traduit / lisible)
/// et éventuellement `code` pour un traitement spécifique (ex: OTP expiré).
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final String? code;

  /// Erreurs de validation par champ, ex: {"email": "Email invalide"}
  final Map<String, String>? fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isValidationError => statusCode == 422 || statusCode == 400;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}
