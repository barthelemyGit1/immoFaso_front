import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/locataire/screens/locataire_shell.dart';
import '../constants/app_constants.dart';

/// Routes nommées, centralisées pour éviter les chaînes de caractères
/// éparpillées dans les écrans.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const otpVerification = '/otp-verification';
  static const forgotPassword = '/forgot-password';

  // Racines par rôle — chaque feature branchera ses sous-routes ici
  // (ex: /locataire/home, /locataire/annonce/:id, ...).
  static const locataireHome = '/locataire';
  static const proprietaireHome = '/proprietaire';
  static const adminHome = '/admin';
}

/// Provider du router. Ré-évalue les redirections à chaque changement
/// de [AuthState] et [OnboardingState] grâce à `refreshListenable`.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AppStartupListenable(ref),
    redirect: (context, state) {
      final onboardingState = ref.read(onboardingControllerProvider);

      // Tant qu'on ne sait pas si l'onboarding a déjà été vu, on reste
      // sur le splash (évite un flash vers /login puis /onboarding).
      if (onboardingState.isLoading || !onboardingState.hasValue) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final hasSeenOnboarding = onboardingState.value!;
      if (!hasSeenOnboarding) {
        return state.matchedLocation == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      final authState = ref.read(authControllerProvider);
      final goingToAuthScreen = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.otpVerification,
        AppRoutes.forgotPassword,
      ].contains(state.matchedLocation);

      // L'onboarding est déjà vu : si l'utilisateur y revient (bouton
      // précédent du navigateur, deep link...), on l'envoie plus loin.
      if (state.matchedLocation == AppRoutes.onboarding) {
        return AppRoutes.splash;
      }

      // Pendant la restauration de session, on reste sur le splash.
      if (authState is AuthInitial || authState is AuthLoading) {
        return state.matchedLocation == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        return goingToAuthScreen ? null : AppRoutes.login;
      }

      if (authState is AuthAuthenticated) {
        // Si un utilisateur connecté atterrit sur une route d'auth ou le
        // splash, on le redirige vers l'accueil correspondant à son rôle.
        if (goingToAuthScreen || state.matchedLocation == AppRoutes.splash) {
          return _homeRouteForRole(authState.user.role);
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final telephone = state.extra as String? ?? '';
          return OtpVerificationScreen(telephone: telephone);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Placeholders — à remplacer par les vraies branches de navigation
      // (ShellRoute avec bottom nav) une fois les écrans métier construits.
      GoRoute(
        path: AppRoutes.locataireHome,
        //builder: (_, __) => const _RoleHomePlaceholder(title: 'Espace Locataire'),
        builder: (_, __) => const LocataireShell(),
      ),
      GoRoute(
        path: AppRoutes.proprietaireHome,
        builder: (_, __) => const _RoleHomePlaceholder(title: 'Espace Propriétaire'),
      ),
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (_, __) => const _RoleHomePlaceholder(title: 'Back-office Admin'),
      ),
    ],
  );
});

String _homeRouteForRole(UserRole role) {
  switch (role) {
    case UserRole.proprietaire:
      return AppRoutes.proprietaireHome;
    case UserRole.admin:
      return AppRoutes.adminHome;
    case UserRole.locataire:
      return AppRoutes.locataireHome;
  }
}

/// Pont entre Riverpod et Listenable (attendu par go_router).
/// Écoute à la fois l'état d'authentification et l'état d'onboarding,
/// puisque les deux influencent la redirection initiale.
class _AppStartupListenable extends ChangeNotifier {
  _AppStartupListenable(this._ref) {
    _ref.listen(authControllerProvider, (_, __) => notifyListeners());
    _ref.listen(onboardingControllerProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

class _RoleHomePlaceholder extends StatelessWidget {
  const _RoleHomePlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$title — écrans à venir'),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, _) => OutlinedButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: const Text('Se déconnecter (test)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}