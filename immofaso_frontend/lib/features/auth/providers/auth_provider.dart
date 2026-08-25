import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/secure_storage_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

/// --- Injection de dépendances de base ---

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    storage: storage,
    onSessionExpired: () async {
      // Force le retour à l'état "non authentifié", ce qui fait
      // automatiquement rediriger le go_router vers /login (cf. app_router.dart).
      ref.read(authControllerProvider.notifier).forceLogout();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

/// --- État d'authentification ---

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

/// Contrôleur central de session, consommé par le router pour les
/// redirections basées sur le rôle et l'état d'authentification.
///
/// Migré vers l'API `Notifier` de Riverpod 3.x (remplace StateNotifier).
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    // Fire-and-forget : la restauration met à jour `state` de façon
    // asynchrone une fois l'état initial construit.
    _tryRestoreSession();
    return const AuthInitial();
  }

  Future<void> _tryRestoreSession() async {
    state = const AuthLoading();
    final user = await _repository.restoreSession();
    state = user != null
        ? AuthAuthenticated(user)
        : const AuthUnauthenticated();
  }

  Future<void> login({
    required String telephone,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repository.login(
        telephone: telephone,
        password: password,
      );
      state = AuthAuthenticated(result.user);
    } on Exception catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> verifyOtp({
    required String telephone,
    required String otpCode,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repository.verifyOtp(
        telephone: telephone,
        otpCode: otpCode,
      );
      state = AuthAuthenticated(result.user);
    } on Exception catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> changePassword({
    required String telephone,
    required String otpCode,
    required String newPassword,
  }) async {
    state = const AuthLoading();
    try {
      await _repository.changerPassword(
        telephone: telephone,
        otpCode: otpCode,
        newPassword: newPassword,
      );
      state = const AuthUnauthenticated();
    } on Exception catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Appelé par l'ApiClient quand le refresh token est invalide.
  void forceLogout() {
    state = const AuthUnauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
