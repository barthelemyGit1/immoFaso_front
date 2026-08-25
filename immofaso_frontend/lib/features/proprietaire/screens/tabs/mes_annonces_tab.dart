import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/annonce_model.dart';
import '../../../../shared/widgets/annonce_card.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../locataire/screens/annonce_detail_screen.dart';
import '../../providers/proprietaire_providers.dart';
import '../publier_annonce_screen.dart';

/// Écran "Annonces" de la maquette : liste complète des annonces du
/// propriétaire, avec accès rapide à la publication.
class MesAnnoncesTab extends ConsumerWidget {
  const MesAnnoncesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesAnnonces = ref.watch(mesAnnoncesProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          BrandHeader(
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFDFAF2C)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PublierAnnonceScreen()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: mesAnnonces.maybeWhen(
                data: (list) => Text(
                  '${list.length} annonces',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Annonce>>(
              value: mesAnnonces,
              onRetry: () => ref.invalidate(mesAnnoncesProvider),
              isEmpty: (list) => list.isEmpty,
              emptyIcon: Icons.home_work_outlined,
              emptyTitle: 'Aucune annonce publiée',
              emptyMessage: "Publiez votre premier logement pour qu'il apparaisse ici.",
              data: (context, list) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final annonce = list[index];
                  return AnnonceCard(
                    annonce: annonce,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AnnonceDetailScreen(annonceId: annonce.id)),
                    ),
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