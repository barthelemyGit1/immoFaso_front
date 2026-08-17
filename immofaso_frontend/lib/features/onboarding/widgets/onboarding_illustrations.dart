import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Illustrations "placeholder" à base d'icônes, dans l'esprit des maquettes
/// Figma (logo maison + silhouettes). À remplacer par les exports SVG/PNG
/// définitifs de la maquette une fois disponibles (voir assets/images/).
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key, this.size = 90});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Image(image: const AssetImage('assets/icons/icon.png'), width: size * 0.6, height: size * 0.6),
    );
  }
}

/// Illustration pour le pitch "propriétaires" : maison + deux silhouettes
/// portées par des mains, comme sur la maquette Onboarding2.
class ProprietaireIllustration extends StatelessWidget {
  const ProprietaireIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          Icon(Icons.holiday_village_rounded, size: 76, color: AppColors.secondary),
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 30, color: AppColors.roleProprietaire),
                const SizedBox(width: 6),
                Icon(Icons.person_2, size: 30, color: AppColors.roleLocataire),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustration pour le pitch "locataires" : silhouette qui reçoit les clés
/// d'un logement, comme sur la maquette Onboarding3.
class LocataireIllustration extends StatelessWidget {
  const LocataireIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_pin_circle_rounded, size: 60, color: AppColors.secondary),
              const SizedBox(width: 10),
              Icon(Icons.key_rounded, size: 34, color: AppColors.primary),
              const SizedBox(width: 6),
              const Icon(Icons.house_rounded, size: 56, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}
