import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';
import 'secure_storage_service.dart';

/// Callback appelé quand le refresh token lui-même est invalide/expiré :
/// on doit déconnecter l'utilisateur et le renvoyer vers l'écran de login.
typedef OnSessionExpired = Future<void> Function();

/// Client HTTP central de l'application, construit autour de Dio.
/// Gère : base URL, headers JSON, injection du JWT, refresh automatique
/// en cas de 401, et normalisation des erreurs en [ApiException].
class ApiClient {
  ApiClient({
    required SecureStorageService storage,
    required OnSessionExpired onSessionExpired,
  })  : _storage = storage,
        _onSessionExpired = onSessionExpired {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      if (const bool.fromEnvironment('dart.vm.product') == false)
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          compact: true,
        ),
    ]);
  }

  late final Dio _dio;
  final SecureStorageService _storage;
  final OnSessionExpired _onSessionExpired;

  // Un seul refresh en vol à la fois, même si plusieurs requêtes
  // échouent en 401 en parallèle.
  Future<String?>? _refreshing;

  Dio get raw => _dio;

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // CA-AUTH: pas de token requis sur les routes publiques d'auth.
        final isAuthRoute = options.path.startsWith('/auth/');
        if (!isAuthRoute) {
          final token = await _storage.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthRoute = error.requestOptions.path.startsWith('/auth/');
        if (error.response?.statusCode == 401 && !isAuthRoute) {
          final newToken = await _refreshAccessToken();
          if (newToken != null) {
            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newToken';
            try {
              final response = await _dio.fetch(retryRequest);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          } else {
            await _storage.clearSession();
            await _onSessionExpired();
          }
        }
        handler.next(error);
      },
    );
  }

  Future<String?> _refreshAccessToken() {
    // Mutualise les refresh concurrents.
    _refreshing ??= _performRefresh().whenComplete(() => _refreshing = null);
    return _refreshing!;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storage.refreshToken;
    if (refreshToken == null) return null;

    try {
      final response = await Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl))
          .post('/auth/refresh', data: {'refreshToken': refreshToken});
      final newAccessToken = response.data['accessToken'] as String?;
      if (newAccessToken != null) {
        await _storage.updateAccessToken(newAccessToken);
      }
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  /// Convertit une [DioException] en [ApiException] lisible.
  static ApiException mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ??
          data['error'] as String? ??
          'Une erreur est survenue.';
      final errors = data['errors'];
      Map<String, String>? fieldErrors;
      if (errors is Map) {
        fieldErrors = errors.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
      return ApiException(
        message: message,
        statusCode: e.response?.statusCode,
        code: data['code'] as String?,
        fieldErrors: fieldErrors,
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Connexion impossible. Vérifiez votre réseau.',
      );
    }

    return ApiException(message: 'Une erreur inattendue est survenue.');
  }
}
