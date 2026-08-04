import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_illustrations.dart';

/// Structure commune à chaque page d'onboarding : logo/illustration,
/// titre "ImmoFaso", texte de description. Le bouton et les indicateurs
/// de page sont gérés par l'écran parent (fixes en bas de l'écran).
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    super.key,
    required this.illustration,
    required this.description,
    this.showAppTitle = true,
  });

  final Widget illustration;
  final String description;
  final bool showAppTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          illustration,
          const SizedBox(height: 24),
          if (showAppTitle) ...[
            Text(
              'ImmoFaso',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Page 1 : présentation générale de la plateforme biface.
class WelcomeOnboardingPage extends StatelessWidget {
  const WelcomeOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      illustration: AppLogoBadge(),
      description:
          "ImmoFaso est une application mobile biface (two-sided platform) qui met en relation deux types d'utilisateurs.",
    );
  }
}

/// Page 2 : pitch côté propriétaires / bailleurs.
class ProprietaireOnboardingPage extends StatelessWidget {
  const ProprietaireOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      illustration: ProprietaireIllustration(),
      description:
          'Les propriétaires / bailleurs publient leurs annonces de logements disponibles, '
          'gèrent leurs biens et reçoivent des demandes directement des locataires.',
    );
  }
}

/// Page 3 : pitch côté locataires / demandeurs.
class LocataireOnboardingPage extends StatelessWidget {
  const LocataireOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingPageContent(
      illustration: LocataireIllustration(),
      description:
          'Les locataires / demandeurs peuvent rechercher un logement selon leurs critères '
          '(ville, quartier, type de logement, nombre de pièces, budget) et contactent '
          'directement les propriétaires.',
    );
  }
}
