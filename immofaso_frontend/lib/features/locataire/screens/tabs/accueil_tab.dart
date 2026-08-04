import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/annonce_providers.dart';
import '../../widgets/annonce_card.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/golden_search_field.dart';
import '../annonce_detail_screen.dart';
import '../resultats_recherche_screen.dart';

/// Écran "SearchPage" de la maquette : salutation, recherche rapide,
/// catégories, liste des annonces récentes.
class AccueilTab extends ConsumerWidget {
  const AccueilTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final prenom = authState is AuthAuthenticated ? authState.user.prenom : '';
    final resultats = ref.watch(resultatsRechercheProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const BrandHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour${prenom.isNotEmpty ? ', $prenom' : ''}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                ),
                Text('Où cherchez-vous ?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
                const SizedBox(height: 16),
                GoldenSearchField(
                  hint: 'Ville, quartier, montant...',
                  readOnly: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ResultatsRechercheScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _CategoriesRow(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AsyncValueView<List<Annonce>>(
              value: resultats,
              onRetry: () => ref.invalidate(resultatsRechercheProvider),
              isEmpty: (list) => list.isEmpty,
              emptyIcon: Icons.home_work_outlined,
              emptyTitle: 'Aucune annonce disponible',
              emptyMessage: 'Les nouvelles annonces publiées par les propriétaires apparaîtront ici.',
              data: (context, annonces) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: annonces.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final annonce = annonces[index];
                  return AnnonceCard(
                    annonce: annonce,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AnnonceDetailScreen(annonceId: annonce.id)),
                    ),
                    onToggleFavori: (isFavori) {
                      ref.read(annonceRepositoryProvider).toggleFavori(annonce.id, isFavori: isFavori);
                      ref.invalidate(resultatsRechercheProvider);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtres = ref.watch(filtresControllerProvider);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TypeLogement.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = TypeLogement.values[index];
          final isSelected = filtres.typeLogement == type;
          return ChoiceChip(
            label: Text(type.label),
            selected: isSelected,
            onSelected: (_) {
              ref.read(filtresControllerProvider.notifier).setTypeLogement(isSelected ? null : type);
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          );
        },
      ),
    );
  }
}