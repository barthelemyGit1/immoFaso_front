import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/annonce_model.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../providers/annonce_providers.dart';
import '../../../../shared/widgets/annonce_card.dart';
import 'annonce_detail_screen.dart';
import 'tabs/recherche_tab.dart';

/// Écran "ResultatFiltrer" de la maquette.
class ResultatsRechercheScreen extends ConsumerWidget {
  const ResultatsRechercheScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtres = ref.watch(filtresControllerProvider);
    final resultats = ref.watch(resultatsRechercheProvider);
    final localisation = (filtres.villeOuQuartier?.isNotEmpty ?? false)
        ? filtres.villeOuQuartier!
        : 'Tous les quartiers';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(localisation, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RechercheTab()),
            ),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filtres'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: resultats.maybeWhen(
                data: (annonces) => Text(
                  '${annonces.length} résultats',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Annonce>>(
              value: resultats,
              onRetry: () => ref.invalidate(resultatsRechercheProvider),
              isEmpty: (list) => list.isEmpty,
              emptyIcon: Icons.search_off_rounded,
              emptyTitle: 'Aucun résultat',
              emptyMessage: 'Essayez de modifier vos critères de recherche.',
              data: (context, annonces) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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