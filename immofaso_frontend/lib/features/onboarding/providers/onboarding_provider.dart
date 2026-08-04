import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/onboarding_local_service.dart';

final onboardingLocalServiceProvider = Provider<OnboardingLocalService>((ref) {
  return OnboardingLocalService();
});

/// État asynchrone : `true` une fois qu'on sait si l'utilisateur a déjà
/// vu l'onboarding (lu depuis le stockage local au démarrage de l'app).
/// Le router attend que cet état soit résolu avant de décider où naviguer.
class OnboardingController extends AsyncNotifier<bool> {
  late final OnboardingLocalService _service;

  @override
  Future<bool> build() async {
    _service = ref.watch(onboardingLocalServiceProvider);
    return _service.hasSeenOnboarding();
  }

  Future<void> completeOnboarding() async {
    await _service.markOnboardingAsSeen();
    state = const AsyncData(true);
  }
}

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, bool>(OnboardingController.new);
