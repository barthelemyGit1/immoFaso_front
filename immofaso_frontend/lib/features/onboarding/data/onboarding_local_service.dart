import 'package:shared_preferences/shared_preferences.dart';

/// Persiste localement si l'utilisateur a déjà vu l'écran d'introduction.
/// Volontairement séparé du `SecureStorageService` : cette donnée n'est
/// pas sensible et n'a pas besoin d'être chiffrée.
class OnboardingLocalService {
  static const _key = 'immofaso_has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
